"""Editor for the extracted 16x16 8x4x4 reference component sheets."""

from __future__ import annotations

import copy
import subprocess
import sys
import tkinter as tk
from pathlib import Path
from tkinter import messagebox, ttk

from PIL import Image

import generate_korean_composite_16x16 as generator


ROOT = Path(__file__).resolve().parent
COMPONENT_DIR = ROOT / "components"
DISPLAY_SCALE = 24
PREVIEW_SCALE = 24
ROLE_LABELS = {"초성": "initial", "중성": "medial", "종성": "final"}


class ComponentEditor(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("16×16 8×4×4 한글 조합 글리프 편집기")
        self.resizable(False, False)
        generator.build_reference_assets()
        self.role_name = tk.StringVar(value="initial")
        self.profile_index = tk.IntVar(value=0)
        self.cell_index = 0
        self.preview_text = tk.StringVar(value="까")
        self.status = tk.StringVar(value="구성요소를 선택하십시오.")
        self.images: dict[tuple[str, int], Image.Image] = {}
        self.defaults: dict[tuple[str, int], Image.Image] = {}
        self.undo_stack: list[list[list[int]]] = []
        self.redo_stack: list[list[list[int]]] = []
        self._load_images()
        self._build_ui()
        self._refresh_profiles()
        self._refresh_cells()
        self._show_current()

    @staticmethod
    def _jamos(role: str) -> tuple[str, ...]:
        return (("",) + generator.CHOSEONG if role == "initial" else
                ("",) + generator.JUNGSEONG if role == "medial" else
                generator.JONGSEONG)

    def _path(self, role: str, profile: int) -> Path:
        return COMPONENT_DIR / role / f"{role}_{profile + 1:02d}_16x16.png"

    def _load_images(self) -> None:
        for role, count in generator.ROLE_PROFILES.items():
            for profile in range(count):
                image = Image.open(self._path(role, profile)).convert("1")
                self.images[(role, profile)] = image
                self.defaults[(role, profile)] = image.copy()

    def _build_ui(self) -> None:
        root = ttk.Frame(self, padding=8)
        root.grid(row=0, column=0)
        left = ttk.Frame(root)
        left.grid(row=0, column=0, sticky="ns", padx=(0, 12))
        ttk.Label(left, text="자모 종류").grid(row=0, column=0, pady=(0, 4))
        tabs = ttk.Notebook(left, width=150, height=30)
        for label in ROLE_LABELS:
            tabs.add(ttk.Frame(tabs), text=label)
        tabs.grid(row=1, column=0)
        tabs.bind("<<NotebookTabChanged>>", self._role_changed)
        self.profile_box = ttk.Combobox(left, state="readonly", width=14)
        self.profile_box.grid(row=2, column=0, pady=(6, 0))
        self.profile_box.bind("<<ComboboxSelected>>", self._profile_changed)
        self.cell_list = tk.Listbox(left, width=15, height=24, exportselection=False)
        self.cell_list.grid(row=3, column=0, pady=(6, 0))
        self.cell_list.bind("<<ListboxSelect>>", self._cell_changed)

        right = ttk.Frame(root)
        right.grid(row=0, column=1, sticky="n")
        edit = ttk.LabelFrame(right, text="현재 16×16 셀", padding=8)
        edit.grid(row=0, column=0, sticky="n")
        self.canvas = tk.Canvas(edit, width=16 * DISPLAY_SCALE, height=16 * DISPLAY_SCALE,
                                bg="black", highlightthickness=1, highlightbackground="#666")
        self.canvas.grid(row=0, column=0)
        self.canvas.bind("<Button-1>", self._toggle_pixel)

        preview = ttk.LabelFrame(right, text="완성 음절 미리보기", padding=8)
        preview.grid(row=0, column=1, sticky="n", padx=(12, 0))
        controls = ttk.Frame(preview)
        controls.grid(row=0, column=0, pady=(0, 6))
        ttk.Label(controls, text="한 글자").grid(row=0, column=0, padx=(0, 4))
        check = (self.register(self._one_char), "%P")
        ttk.Entry(controls, textvariable=self.preview_text, width=4, validate="key",
                  validatecommand=check).grid(row=0, column=1)
        ttk.Button(controls, text="갱신", command=self._refresh_preview).grid(row=0, column=2, padx=(4, 0))
        self.preview = tk.Canvas(preview, width=16 * PREVIEW_SCALE, height=16 * PREVIEW_SCALE,
                                 bg="black", highlightthickness=1, highlightbackground="#666")
        self.preview.grid(row=1, column=0)

        buttons = ttk.Frame(right)
        buttons.grid(row=1, column=0, columnspan=2, pady=(8, 0), sticky="w")
        for column, label, command in (
            (0, "실행 취소", self._undo), (1, "다시 실행", self._redo),
            (2, "현재 초기화", self._reset), (3, "전체 저장", self._save_all),
            (4, "시험판 재생성", self._rebuild_trial),
        ):
            ttk.Button(buttons, text=label, command=command).grid(row=0, column=column, padx=2)
        ttk.Label(right, textvariable=self.status).grid(row=2, column=0, columnspan=2, sticky="w", pady=(6, 0))

    @staticmethod
    def _one_char(value: str) -> bool:
        return len(value) <= 1

    def _role_changed(self, event=None) -> None:
        index = event.widget.index(event.widget.select()) if event else 0
        self.role_name.set(tuple(ROLE_LABELS.values())[index])
        self.profile_index.set(0)
        self.cell_index = 0
        self._refresh_profiles()
        self._refresh_cells()
        self._show_current()

    def _profile_changed(self, _event=None) -> None:
        self.profile_index.set(self.profile_box.current())
        self.cell_index = 0
        self._refresh_cells()
        self._show_current()

    def _cell_changed(self, _event=None) -> None:
        selected = self.cell_list.curselection()
        if selected:
            self.cell_index = selected[0]
            self._show_current()

    def _refresh_profiles(self) -> None:
        role = self.role_name.get()
        values = [f"{generator.ROLE_LABELS[role]} {i + 1}벌" for i in range(generator.ROLE_PROFILES[role])]
        self.profile_box["values"] = values
        self.profile_box.current(self.profile_index.get())

    def _refresh_cells(self) -> None:
        self.cell_list.delete(0, tk.END)
        for jamo in self._jamos(self.role_name.get()):
            self.cell_list.insert(tk.END, jamo or "(채움 셀)")
        self.cell_list.selection_set(self.cell_index)
        self.cell_list.see(self.cell_index)

    def _key(self) -> tuple[str, int]:
        return self.role_name.get(), self.profile_index.get()

    def _origin(self) -> tuple[int, int]:
        return (self.cell_index % generator.SHEET_COLUMNS) * 16, (self.cell_index // generator.SHEET_COLUMNS) * 16

    def _read_current(self) -> list[list[int]]:
        image = self.images[self._key()]
        x0, y0 = self._origin()
        return [[int(bool(image.getpixel((x0 + x, y0 + y)))) for x in range(16)] for y in range(16)]

    def _write_current(self, bitmap: list[list[int]]) -> None:
        image = self.images[self._key()]
        x0, y0 = self._origin()
        for y in range(16):
            for x in range(16):
                image.putpixel((x0 + x, y0 + y), bitmap[y][x])

    def _draw_bitmap(self, canvas: tk.Canvas, bitmap: bytes, scale: int) -> None:
        canvas.delete("all")
        for y in range(16):
            row = int.from_bytes(bitmap[y * 2:y * 2 + 2], "big")
            for x in range(16):
                on = bool(row & (1 << (15 - x)))
                canvas.create_rectangle(x * scale, y * scale, (x + 1) * scale, (y + 1) * scale,
                                        fill="white" if on else "black", outline="#444")

    def _show_current(self) -> None:
        self._draw_bitmap(self.canvas, generator.glyph_from_image(self._current_image()), DISPLAY_SCALE)
        role = self.role_name.get()
        jamo = self._jamos(role)[self.cell_index] or "(채움 셀)"
        self.status.set(f"{generator.ROLE_LABELS[role]} {self.profile_index.get() + 1}벌 / {jamo}")
        self._refresh_preview()

    def _current_image(self) -> Image.Image:
        image = Image.new("1", (16, 16), 0)
        x0, y0 = self._origin()
        source = self.images[self._key()]
        for y in range(16):
            for x in range(16):
                image.putpixel((x, y), source.getpixel((x0 + x, y0 + y)))
        return image

    def _read_all_components(self):
        result = {}
        for role, profiles in generator.ROLE_PROFILES.items():
            result[role] = {}
            for profile in range(profiles):
                image = self.images[(role, profile)]
                entries = {}
                for cell, jamo in enumerate(self._jamos(role)):
                    x0, y0 = (cell % 10) * 16, (cell // 10) * 16
                    crop = image.crop((x0, y0, x0 + 16, y0 + 16))
                    entries[jamo] = generator.glyph_from_image(crop)
                result[role][profile] = entries
        return result

    def _refresh_preview(self) -> None:
        text = self.preview_text.get()
        if len(text) != 1:
            return
        try:
            glyph = generator.compose(text, self._flatten_components())
        except ValueError:
            return
        self._draw_bitmap(self.preview, glyph, PREVIEW_SCALE)

    def _flatten_components(self):
        nested = self._read_all_components()
        return {(role, profile, jamo): glyph for role, profiles in nested.items()
                for profile, entries in profiles.items() for jamo, glyph in entries.items()}

    def _toggle_pixel(self, event) -> None:
        x, y = min(15, max(0, event.x // DISPLAY_SCALE)), min(15, max(0, event.y // DISPLAY_SCALE))
        before = self._read_current()
        after = copy.deepcopy(before)
        after[y][x] ^= 1
        self.undo_stack.append(before)
        self.redo_stack.clear()
        self._write_current(after)
        self._show_current()

    def _undo(self) -> None:
        if self.undo_stack:
            self.redo_stack.append(self._read_current())
            self._write_current(self.undo_stack.pop())
            self._show_current()

    def _redo(self) -> None:
        if self.redo_stack:
            self.undo_stack.append(self._read_current())
            self._write_current(self.redo_stack.pop())
            self._show_current()

    def _reset(self) -> None:
        original = self.defaults[self._key()]
        x0, y0 = self._origin()
        self.undo_stack.append(self._read_current())
        self._write_current([[int(bool(original.getpixel((x, y)))) for x in range(16)] for y in range(16)])
        self.redo_stack.clear()
        self._show_current()

    def _save_all(self) -> None:
        for key, image in self.images.items():
            image.save(self._path(*key))
        self.status.set("모든 16×16 자모 시트를 저장했습니다.")

    def _rebuild_trial(self) -> None:
        self._save_all()
        result = subprocess.run([sys.executable, str(ROOT / "generate_korean_composite_16x16.py"), "--trial"],
                                cwd=ROOT, capture_output=True, text=True)
        if result.returncode:
            messagebox.showerror("재생성 실패", result.stderr or result.stdout)
        else:
            messagebox.showinfo("완료", "16×16 시험판을 갱신했습니다.")


if __name__ == "__main__":
    ComponentEditor().mainloop()
