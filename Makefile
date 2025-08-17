# LineAgent Project Makefile
# Centralized build and development commands

.PHONY: help start-lineage-visualizer stop-lineage-visualizer install-lineage-visualizer-dependencies clean-all-stack

# Load environment variables from .env file
ifneq (,$(wildcard .env))
    include .env
    export
endif

# =============================================================================
# LINEAGE VISUALIZER SERVER

# Start lineage visualizer in background
start-lineage-visualizer:
	@echo "📦 Installing lineage visualizer dependencies..."
	pnpm install
	@echo "🚀 Starting lineage visualizer in background..."
	@if pgrep -f "pnpm.*run.*dev" > /dev/null; then \
		echo "⚠️  Lineage visualizer is already running!"; \
		echo "   Use 'make stop-lineage-visualizer' to stop it first"; \
	else \
		pnpm run dev > /dev/null 2>&1 & \
		echo "⏳ Waiting for lineage visualizer to start up..."; \
		while ! curl -s http://localhost:3000 > /dev/null 2>&1; do \
			sleep 1; \
		done; \
		echo "✅ Lineage visualizer started in background"; \
		echo "🌐 Server is available at http://localhost:3000"; \
		echo "🛑 Use 'make stop-lineage-visualizer' to stop the lineage visualizer"; \
	fi

# Stop lineage visualizer
stop-lineage-visualizer:
	@echo "🛑 Stopping lineage visualizer..."
	@pkill -f "pnpm.*run.*dev" || echo "No lineage visualizer process found"
	@echo "✅ Lineage visualizer stopped"

# =============================================================================
# CLEANUP COMMANDS ############################################################
# =============================================================================


# Clean up temporary files and kill processes
clean-all-stack:
	@echo "🧹 Cleaning up temporary files and processes..."
	@echo "🛑 Killing processes on ports  3000."
	@lsof -ti:3000 | xargs kill -9 2>/dev/null || echo "No process on port 3000"
	@echo "🗑️  Cleaning up temporary files..."
	@find . -name "*.log" -type f -delete
	@find . -name "temp_*.json" -type f -delete
	@find . -name "generated-*.json" -type f -delete
	@echo "🗑️  Removing data folders..."
	@rm -rf node_modules 2>/dev/null || echo "No node_modules folder found"
	@rm -rf .pnpm-store 2>/dev/null || echo "No .pnpm-store folder found"
	@rm -rf .next 2>/dev/null || echo "No .next folder found"
	@echo "✅ Cleanup completed!"


