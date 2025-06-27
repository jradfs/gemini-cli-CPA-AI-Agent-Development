#!/bin/bash
echo "Removing all 17 MCP servers..."

claude mcp remove brave-search
claude mcp remove supabase-server
claude mcp remove sequential-thinking
claude mcp remove context7
claude mcp remove puppeteer
claude mcp remove browsermcp
claude mcp remove github
claude mcp remove desktop-commander
claude mcp remove fastapi-mcp
claude mcp remove docker-mcp
claude mcp remove mcp_docker_mcp_toolkit
claude mcp remove apify-actors
claude mcp remove n8n-main
claude mcp remove py-mcp-youtube-toolbox
claude mcp remove accounting-firm-database
claude mcp remove bookkeeping-ai-database
claude mcp remove dev-admin-database

echo "All MCP servers removed! Verifying..."
claude mcp list