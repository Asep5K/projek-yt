# Output name
OUTPUT = yt-cli.py
SRC = lib/variable.py \
      lib/ascii.py \
      lib/download.py \
      lib/install.py \
      lib/utils.py \
      lib/play.py \
	  lib/menu.py \
      lib/main.py

#       lib/help.py \
# Default command: build
all: $(OUTPUT)

# Build process
$(OUTPUT): $(SRC)
	@echo "🔨 Building $@ ..."
	@cat $(SRC) > $(OUTPUT)
	@chmod +x $(OUTPUT)
	@echo "✅ Build completed: $(OUTPUT)"

# Clean build artifacts
clean:
	@rm -f $(OUTPUT)
	@echo "🧹 Clean done."
