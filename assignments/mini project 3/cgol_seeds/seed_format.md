# CGOL Seed Format
All files in this directory (.mem files) follow this format:

- Docstring on top describing the seed.
- For each line, there is a `0` or `1` only. A `0` represents a dead cell while a `1` represents an alive cell.
- Each line corresponds to a cell in the 8x8 grid in the WS2812B LED Matrix.
- There are only 64 cells, therefore there should only be 64 entries in the .mem file.
- Note: This format does not store color information.