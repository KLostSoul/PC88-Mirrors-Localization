from .main import main


if __name__ == "__main__":
    try:
        main()
    except FileNotFoundError as error:
        print(f"ERROR: {error}")
        raise SystemExit(2)
