# DSL - AI Workflow Applications

This repository contains a collection of AI workflow applications built for the Dify platform. All applications are configured with Japanese language interfaces and designed for business automation tasks.

## 📁 Applications Overview

### 01_ビジネスアイデア (Business Idea Generation)
- **Mode**: Completion
- **Purpose**: Generate creative business ideas based on user input
- **Features**: Simple AI completion with customizable parameters

### 02_社内規則 (Company Rules Chatbot)
- **Mode**: Advanced Chat
- **Purpose**: Knowledge-based chatbot for company rules and regulations
- **Features**: RAG (Retrieval-Augmented Generation) with document upload support

### 03_広告キャッチコピー (Advertisement Copy Creation)
- **Mode**: Advanced Chat
- **Purpose**: Create compelling advertisement copy and catchphrases
- **Features**: Multi-step LLM workflow with iterative refinement

### 04_プレスリリース (Press Release Creation)
- **Mode**: Advanced Chat
- **Purpose**: Generate professional press releases
- **Features**: LLM feedback loop with structured output formatting

### 05_多言語対応チャットボット (Multilingual Chatbot)
- **Mode**: Advanced Chat
- **Purpose**: Multi-language conversation support
- **Features**: Language detection and switching, conversation variables

### 06_注文書から情報抽出 (Order Information Extraction)
- **Mode**: Advanced Chat
- **Purpose**: Extract structured information from order documents
- **Features**: Document processing, parameter extraction, Excel/PDF support

### 07_複数LLM比較 (Multi-LLM Comparison)
- **Mode**: Advanced Chat
- **Purpose**: Compare responses from multiple language models
- **Features**: Side-by-side model comparison with configurable parameters

### 08_音声文字起こし (Audio Transcription)
- **Mode**: Advanced Chat
- **Purpose**: Transcribe audio files with speaker separation
- **Features**: Audio processing, speaker identification

### 09_PDF文字起こし（AIなし）(PDF Text Extraction - No AI)
- **Mode**: Workflow
- **Purpose**: Extract text from PDF documents without AI processing
- **Features**: Direct PDF text extraction pipeline

## 🛠️ Technical Details

### Platform
- **Framework**: Dify AI Platform
- **Version**: 0.1.5 - 0.3.0
- **Language**: Japanese

### AI Models
- **Primary**: GPT-4o, GPT-4o-mini
- **Provider**: OpenAI
- **Configuration**: Customizable temperature settings (typically 0.7)

### File Support
- **Documents**: PDF, Excel (.xlsx), Word (.docx)
- **Images**: PNG, JPG, GIF (up to 10MB)
- **Audio**: M4A and other common formats
- **Video**: Up to 100MB
- **Batch Processing**: Up to 5 files

## 🚀 Getting Started

1. Import the desired YAML configuration file into your Dify platform
2. Configure the OpenAI API settings
3. Upload any required knowledge base documents (for RAG applications)
4. Test the application with the provided sample data

## 📄 Configuration Structure

Each application includes:
- **App metadata**: Name, description, icon
- **Workflow definition**: Node-based logic with conversation variables
- **Feature settings**: File upload, speech processing, UI components
- **Sample data**: Test files and input examples

## 🔧 Development

### Adding New Applications
1. Create a numbered directory with Japanese name
2. Include YAML workflow configuration
3. Add sample data files for testing
4. Follow existing naming conventions

### Customization
- Modify `conversation_variables` for data persistence
- Adjust `temperature` settings for creativity control
- Configure `file_upload` features for document processing
- Update prompts and responses for specific use cases

## 📋 Requirements

- Dify Platform access
- OpenAI API key
- Japanese language support in your environment

## 🤝 Contributing

This repository contains business-focused AI applications. When contributing:
- Follow Japanese naming conventions
- Test with Japanese language inputs
- Include sample data for new applications
- Document any new workflow patterns

## 📞 Support

For questions about specific applications or configuration, refer to the individual YAML files and sample data in each directory.