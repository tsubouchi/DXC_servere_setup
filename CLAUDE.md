# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains a collection of DSL AI workflow applications designed for Dify platform. Each directory represents a distinct AI-powered workflow application with specific business use cases.

## Application Structure

The repository is organized into numbered directories, each containing a complete Dify workflow application:

- **01_ビジネスアイデア**: Business idea generation with completion mode
- **02_社内規則**: Company regulation chatbot using RAG (Retrieval-Augmented Generation)
- **03_広告キャッチコピー**: Advertisement copywriting generator
- **04_プレスリリース**: Press release creation workflow  
- **05_多言語対応チャットボット**: Multi-language chatbot support
- **06_注文書から情報抽出**: Order form information extraction with document processing
- **07_複数LLM比較**: Multi-LLM comparison chatbot with model switching
- **08_音声文字起こし**: Audio transcription with speaker separation
- **09_PDF文字起こし（AIなし）**: PDF text extraction without AI processing

## Configuration Files

Each workflow application is defined by:
- **`.yml` file**: Main workflow configuration containing:
  - Application metadata (name, description, icon)
  - Model configuration (OpenAI GPT-4o/GPT-4o-mini primarily)
  - Workflow graph with nodes and edges
  - Input/output parameters and file upload settings
  - Variable definitions and conversation state

## Key Workflow Patterns

1. **Completion Mode**: Simple prompt-response applications (Business Ideas)
2. **Advanced Chat Mode**: Complex multi-node workflows with conditional logic
3. **RAG Integration**: Knowledge retrieval systems (Company Regulations)
4. **Document Processing**: File upload and text extraction workflows (Order Forms, PDF processing)
5. **Model Switching**: Dynamic LLM selection based on user input (Multi-LLM)
6. **Parameter Extraction**: Structured data extraction from documents
7. **Template Transformation**: Formatted output generation

## Dify Platform Integration

These workflows are designed for the Dify platform and include:
- OpenAI provider integration with marketplace plugins
- File upload capabilities (documents, images, audio)
- Conversation variable management
- Template-based response formatting
- Conditional workflow branching

## Working with Workflows

When modifying workflows:
1. Maintain the existing YAML structure and node relationships
2. Preserve the graph topology (nodes, edges, positions)
3. Keep variable selectors and conversation state intact
4. Test workflow logic flow before deployment
5. Ensure model provider configurations remain valid

## Sample Data

Several directories include sample files for testing:
- CSV templates for structured data
- PDF and Excel files for document processing workflows
- Audio files for transcription testing
- Text input examples for prompt testing