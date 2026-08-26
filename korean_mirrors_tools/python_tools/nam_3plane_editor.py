"""Editor for Mirrors NAM graphics stored as three PC-8801 bit planes.

The game build still consumes one indexed PNG per NAM entry.  This tool makes
the three bits of every palette index visible and editable as separate 1bpp
planes, then merges them back into a compatible indexed PNG.
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

from PIL import Image, ImageTk


PLANE_COUNT = 3
MAX_NAM_INDEX = (1 << PLANE_COUNT) - 1
MAX_HISTORY = 100
DEFAULT_PALETTE = [component for index in range(8) for component in (index * 32,) * 3]
DEFAULT_PALETTE.extend([0] * (768 - len(DEFAULT_PALETTE)))


def _normalise_palette(palette: Sequence[int] | None) -> list[int]:
    if palette is None:
        return list(DEFAULT_PALETTE)
    result = list(palette[:768])
    result.extend([0] * (768 - len(result)))
    return result


def _pixels(image: Image.Image) -> list[int]:
    if hasattr(image, "get_flattened_data"):
        return list(image.get_flattened_data())
    return list(image.getdata())


PlaneState = tuple[bytes, bytes, bytes]


class PlaneHistory:
    """Undo/redo history for the three bit-plane buffers."""

    def __init__(self, original: PlaneState) -> None:
        self.original = original
        self.undo_stack: list[PlaneState] = []
        self.redo_stack: list[PlaneState] = []

    def record_change(self, before: PlaneState) -> None:
        self.undo_stack.append(before)
        if len(self.undo_stack) > MAX_HISTORY:
            self.undo_stack.pop(0)
        self.redo_stack.clear()

    def undo(self, current: PlaneState) -> PlaneState | None:
        if not self.undo_stack:
            return None
        previous = self.undo_stack.pop()
        self.redo_stack.append(current)
        return previous

    def redo(self, current: PlaneState) -> PlaneState | None:
        if not self.redo_stack:
            return None
        next_state = self.redo_stack.pop()
        self.undo_stack.append(current)
        return next_state


@dataclass
class NamPlaneDocument:
    width: int
    height: int
    planes: list[bytearray]
    palette: list[int]
    source_name: str = "NAM"

    @classmethod
    def from_nam_png(cls, filename: str | Path) -> "NamPlaneDocument":
        path = Path(filename)
        image = Image.open(path).convert("P")
        pixels = _pixels(image)
        invalid = sorted(set(pixel for pixel in pixels if pixel > MAX_NAM_INDEX))
        if invalid:
            raise ValueError(
                "NAM PNG must use palette indices 0 through 7; "
                f"found {', '.join(map(str, invalid[:8]))}."
            )

        planes = [bytearray((pixel >> plane) & 1 for pixel in pixels) for plane in range(PLANE_COUNT)]
        return cls(
            image.width,
            image.height,
            planes,
            _normalise_palette(image.getpalette()),
            path.stem,
        )

    @classmethod
    def from_plane_pngs(cls, filenames: Iterable[str | Path]) -> "NamPlaneDocument":
        paths = [Path(filename) for filename in filenames]
        if len(paths) != PLANE_COUNT:
            raise ValueError("Exactly three plane PNG files are required.")

        images = [Image.open(path).convert("1") for path in paths]
        sizes = {image.size for image in images}
        if len(sizes) != 1:
            raise ValueError("All three plane PNG files must have the same dimensions.")

        width, height = images[0].size
        planes = [bytearray(1 if pixel else 0 for pixel in _pixels(image)) for image in images]
        base_name = paths[0].stem.replace("_plane0_1bpp", "")
        return cls(width, height, planes, list(DEFAULT_PALETTE), base_name)

    def _validate_plane(self, plane: int) -> None:
        if plane < 0 or plane >= PLANE_COUNT:
            raise ValueError(f"Plane must be 0 through {PLANE_COUNT - 1}.")

    def plane_image(self, plane: int) -> Image.Image:
        self._validate_plane(plane)
        image = Image.new("1", (self.width, self.height))
        image.putdata([255 if bit else 0 for bit in self.planes[plane]])
        return image

    def merged_image(self) -> Image.Image:
        pixels = [
            self.planes[0][index]
            | (self.planes[1][index] << 1)
            | (self.planes[2][index] << 2)
            for index in range(self.width * self.height)
        ]
        image = Image.new("P", (self.width, self.height))
        image.putpalette(self.palette)
        image.putdata(pixels)
        return image

    def set_bit(self, plane: int, x: int, y: int, value: int) -> None:
        self._validate_plane(plane)
        if not (0 <= x < self.width and 0 <= y < self.height):
            return
        self.planes[plane][y * self.width + x] = 1 if value else 0

    def save_planes(self, output_dir: str | Path, base_name: str | None = None) -> list[Path]:
        directory = Path(output_dir)
        directory.mkdir(parents=True, exist_ok=True)
        stem = base_name or self.source_name
        paths = []
        for plane in range(PLANE_COUNT):
            output = directory / f"{stem}_plane{plane}_1bpp.png"
            self.plane_image(plane).save(output, format="PNG", bits=1)
            paths.append(output)
        return paths

    def save_merged(self, filename: str | Path) -> Path:
        output = Path(filename)
        output.parent.mkdir(parents=True, exist_ok=True)
        self.merged_image().save(output, format="PNG", bits=8)
        return output


class NamPlaneEditor:
    SCALE = 4

    def __init__(self) -> None:
        import tkinter as tk
        from tkinter import filedialog, messagebox

        self.tk = tk
        self.filedialog = filedialog
        self.messagebox = messagebox
        self.root = tk.Tk()
        self.root.title("Mirrors NAM 3-Plane Editor")
        self.document: NamPlaneDocument | None = None
        self.history: PlaneHistory | None = None
        self.stroke_before: PlaneState | None = None
        self.stroke_changed = False
        self.images: list[ImageTk.PhotoImage | None] = [None] * (PLANE_COUNT + 1)
        self.canvases: list[tk.Canvas] = []
        self.status = tk.StringVar(value="NAM PNG를 불러오십시오.")
        self._create_widgets()

    def _create_widgets(self) -> None:
        tk = self.tk
        toolbar = tk.Frame(self.root, padx=8, pady=8)
        toolbar.pack(fill="x")
        tk.Button(toolbar, text="NAM PNG 불러오기", command=self.load_nam).pack(side="left", padx=(0, 4))
        tk.Button(toolbar, text="Plane 3장 불러오기", command=self.load_planes).pack(side="left", padx=4)
        tk.Button(toolbar, text="되돌리기", command=self.undo).pack(side="left", padx=(16, 4))
        tk.Button(toolbar, text="다시 실행", command=self.redo).pack(side="left", padx=4)
        tk.Button(toolbar, text="불러온 상태로 되돌리기", command=self.reset_to_original).pack(side="left", padx=4)
        tk.Button(toolbar, text="분리 PNG 저장", command=self.save_planes).pack(side="left", padx=4)
        tk.Button(toolbar, text="NAM PNG 통합 저장", command=self.save_merged).pack(side="left", padx=4)

        tk.Label(
            self.root,
            text="좌클릭: 비트 1  |  우클릭: 비트 0  |  드래그 가능",
            anchor="w",
            padx=8,
        ).pack(fill="x")

        for plane in range(PLANE_COUNT):
            frame = tk.LabelFrame(self.root, text=f"Plane {plane} (1bpp)", padx=4, pady=4)
            frame.pack(fill="x", padx=8, pady=3)
            canvas = tk.Canvas(frame, background="#202020", highlightthickness=1, highlightbackground="#808080")
            canvas.pack(anchor="w")
            canvas.bind("<Button-1>", lambda event, p=plane: self.begin_stroke(event, p, 1))
            canvas.bind("<B1-Motion>", lambda event, p=plane: self.paint(event, p, 1))
            canvas.bind("<ButtonRelease-1>", self.end_stroke)
            canvas.bind("<Button-3>", lambda event, p=plane: self.begin_stroke(event, p, 0))
            canvas.bind("<B3-Motion>", lambda event, p=plane: self.paint(event, p, 0))
            canvas.bind("<ButtonRelease-3>", self.end_stroke)
            self.canvases.append(canvas)

        preview_frame = tk.LabelFrame(self.root, text="통합 NAM 미리보기", padx=4, pady=4)
        preview_frame.pack(fill="x", padx=8, pady=3)
        self.preview = tk.Canvas(preview_frame, background="#202020", highlightthickness=1, highlightbackground="#808080")
        self.preview.pack(anchor="w")
        tk.Label(self.root, textvariable=self.status, anchor="w", padx=8, pady=8).pack(fill="x")
        self.root.bind_all("<Control-z>", self.undo)
        self.root.bind_all("<Control-y>", self.redo)
        self.root.bind_all("<Control-Shift-Z>", self.redo)

    def _load_document(self, document: NamPlaneDocument) -> None:
        self.document = document
        self.history = PlaneHistory(self.snapshot())
        self.stroke_before = None
        self.stroke_changed = False
        self.refresh_all()
        self.status.set(
            f"{document.source_name}: {document.width}×{document.height}, "
            "3-plane 편집 준비 완료"
        )

    def load_nam(self) -> None:
        filename = self.filedialog.askopenfilename(
            title="NAM PNG 선택",
            filetypes=[("PNG files", "*.png"), ("All files", "*.*")],
        )
        if not filename:
            return
        try:
            self._load_document(NamPlaneDocument.from_nam_png(filename))
        except (OSError, ValueError) as error:
            self.messagebox.showerror("NAM PNG 오류", str(error))

    def load_planes(self) -> None:
        filenames = self.filedialog.askopenfilenames(
            title="Plane 0, 1, 2 PNG를 순서대로 선택",
            filetypes=[("PNG files", "*.png"), ("All files", "*.*")],
        )
        if not filenames:
            return
        try:
            self._load_document(NamPlaneDocument.from_plane_pngs(filenames))
        except (OSError, ValueError) as error:
            self.messagebox.showerror("Plane PNG 오류", str(error))

    def _display_image(self, canvas, image: Image.Image, image_index: int) -> None:
        scaled = image.resize((image.width * self.SCALE, image.height * self.SCALE), Image.Resampling.NEAREST)
        photo = ImageTk.PhotoImage(scaled)
        self.images[image_index] = photo
        canvas.configure(width=scaled.width, height=scaled.height)
        canvas.delete("all")
        canvas.create_image(0, 0, image=photo, anchor="nw")

    def refresh_all(self) -> None:
        if self.document is None:
            return
        for plane, canvas in enumerate(self.canvases):
            self._display_image(canvas, self.document.plane_image(plane), plane)
        self._display_image(self.preview, self.document.merged_image(), PLANE_COUNT)

    def paint(self, event, plane: int, value: int) -> None:
        if self.document is None:
            return
        x = event.x // self.SCALE
        y = event.y // self.SCALE
        if not (0 <= x < self.document.width and 0 <= y < self.document.height):
            return
        previous = self.document.planes[plane][y * self.document.width + x]
        self.document.set_bit(plane, x, y, value)
        if previous != value:
            self.stroke_changed = True
            self.refresh_all()

    def snapshot(self) -> PlaneState:
        if self.document is None:
            raise RuntimeError("No NAM document is loaded.")
        return tuple(bytes(plane) for plane in self.document.planes)  # type: ignore[return-value]

    def restore(self, state: PlaneState) -> None:
        if self.document is None:
            return
        self.document.planes = [bytearray(plane) for plane in state]
        self.refresh_all()

    def begin_stroke(self, event, plane: int, value: int) -> None:
        if self.document is None:
            return
        self.stroke_before = self.snapshot()
        self.stroke_changed = False
        self.paint(event, plane, value)

    def end_stroke(self, _event=None) -> None:
        if self.history is not None and self.stroke_before is not None and self.stroke_changed:
            self.history.record_change(self.stroke_before)
            self.status.set("편집 적용됨. Ctrl+Z로 되돌릴 수 있습니다.")
        self.stroke_before = None
        self.stroke_changed = False

    def undo(self, _event=None) -> str:
        if self.history is None or self.document is None:
            return "break"
        previous = self.history.undo(self.snapshot())
        if previous is not None:
            self.restore(previous)
            self.status.set("되돌리기 완료")
        return "break"

    def redo(self, _event=None) -> str:
        if self.history is None or self.document is None:
            return "break"
        next_state = self.history.redo(self.snapshot())
        if next_state is not None:
            self.restore(next_state)
            self.status.set("다시 실행 완료")
        return "break"

    def reset_to_original(self) -> None:
        if self.history is None or self.document is None:
            return
        current = self.snapshot()
        if current == self.history.original:
            return
        if not self.messagebox.askyesno("불러온 상태로 되돌리기", "현재 편집 내용을 모두 되돌리겠습니까?"):
            return
        self.history.record_change(current)
        self.restore(self.history.original)
        self.status.set("불러온 상태로 되돌렸습니다. Ctrl+Z로 취소할 수 있습니다.")

    def save_planes(self) -> None:
        if self.document is None:
            self.messagebox.showwarning("저장할 데이터 없음", "먼저 NAM PNG 또는 Plane PNG를 불러오십시오.")
            return
        directory = self.filedialog.askdirectory(title="분리 PNG 저장 폴더 선택")
        if not directory:
            return
        paths = self.document.save_planes(directory)
        self.status.set("분리 PNG 저장 완료: " + ", ".join(path.name for path in paths))

    def save_merged(self) -> None:
        if self.document is None:
            self.messagebox.showwarning("저장할 데이터 없음", "먼저 NAM PNG 또는 Plane PNG를 불러오십시오.")
            return
        filename = self.filedialog.asksaveasfilename(
            title="통합 NAM PNG 저장",
            defaultextension=".png",
            initialfile=f"{self.document.source_name}.png",
            filetypes=[("PNG files", "*.png")],
        )
        if not filename:
            return
        output = self.document.save_merged(filename)
        self.status.set(f"통합 NAM PNG 저장 완료: {output}")

    def run(self) -> None:
        self.root.mainloop()


def _split_command(source: str, output_dir: str) -> None:
    document = NamPlaneDocument.from_nam_png(source)
    paths = document.save_planes(output_dir)
    print("\n".join(str(path) for path in paths))


def _merge_command(planes: Sequence[str], output: str) -> None:
    document = NamPlaneDocument.from_plane_pngs(planes)
    print(document.save_merged(output))


def main() -> None:
    parser = argparse.ArgumentParser(description="Split, edit, and merge Mirrors NAM 3-plane graphics.")
    command = parser.add_mutually_exclusive_group()
    command.add_argument("--split", metavar="NAM_PNG", help="split one NAM PNG into three 1bpp PNGs")
    command.add_argument("--merge", nargs=3, metavar=("PLANE0", "PLANE1", "PLANE2"), help="merge three 1bpp plane PNGs")
    parser.add_argument("--output", metavar="PATH", help="output directory for --split or PNG file for --merge")
    arguments = parser.parse_args()

    if arguments.split:
        if not arguments.output:
            parser.error("--split requires --output DIRECTORY")
        _split_command(arguments.split, arguments.output)
        return
    if arguments.merge:
        if not arguments.output:
            parser.error("--merge requires --output NAM.png")
        _merge_command(arguments.merge, arguments.output)
        return

    NamPlaneEditor().run()


if __name__ == "__main__":
    main()
