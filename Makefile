# Output name
OUTPUT = yt-termux.sh
SRC = lib/variable.sh \
      lib/ascii.sh \
      lib/utils.sh \
      lib/install.sh \
      lib/download.sh \
      lib/play.sh \
      lib/menus.sh \
      lib/main.sh

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
