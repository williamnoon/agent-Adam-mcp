# Agent Adam 🤖

**AI-Powered GoHighLevel Integration on Internet Computer**

Agent Adam is an intelligent assistant that seamlessly integrates with GoHighLevel CRM, powered by the Internet Computer blockchain for unparalleled security, transparency, and reliability.

## ✨ Features

- **🧠 Natural Language Processing**: Understand and execute complex GHL commands in plain English
- **🔗 Multi-Channel Integration**: Works with GHL Voice, Chat, Webhooks, and Admin interfaces
- **⚡ Real-time Processing**: Instant command execution and response generation
- **🛡️ Blockchain Security**: Powered by Internet Computer for tamper-proof operations
- **📊 Advanced Analytics**: Built-in metrics and performance tracking
- **🎨 Professional UI**: Modern, responsive interface optimized for GHL iframe embedding

## 🚀 Quick Start

### Prerequisites

- **Node.js** (v18 or higher)
- **DFX SDK** (latest version)
- **GoHighLevel Account** (with webhook/integration access)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/agent-adam-mcp.git
   cd agent-adam-mcp
   ```

2. **Run setup script**
   ```bash
   ./scripts/setup.sh
   ```

3. **Start local development**
   ```bash
   dfx start --background
   ./scripts/deploy.sh local
   ```

4. **Access the interface**
   - Frontend: `http://127.0.0.1:4943/?canisterId={frontend-id}`
   - Canister: `http://127.0.0.1:4943/?canisterId={agent-adam-id}`

## 🏗️ Architecture

### Smart Contract Layer (Motoko)
- **Main Actor**: Core command processing and state management
- **Type System**: Comprehensive type definitions for GHL integration
- **Command Processor**: Natural language interpretation engine
- **GHL Integration**: Channel-specific handlers and formatters

### Frontend Layer (JavaScript)
- **Chat Interface**: Professional chat UI with real-time updates
- **ICP Service**: Blockchain communication layer
- **GHL Bridge**: PostMessage API for iframe integration
- **Component System**: Modular, reusable UI components

## 📋 Project Structure

```
agent-adam-mcp/
├── src/
│   ├── AgentAdam/          # Motoko smart contracts
│   │   ├── main.mo         # Main actor
│   │   ├── Types.mo        # Type definitions
│   │   ├── CommandProcessor.mo
│   │   └── GHLIntegration.mo
│   └── frontend/           # Web interface
│       ├── index.html      # Main HTML
│       ├── app.js          # Application logic
│       ├── styles.css      # Styling
│       ├── components/     # UI components
│       └── services/       # API services
├── scripts/                # Build and deployment
├── tests/                  # Test suites
├── docs/                   # Documentation
├── dfx.json               # DFX configuration
├── package.json           # Node dependencies
└── vessel.dhall           # Motoko packages
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file with your configuration:

```env
# Network Configuration
NETWORK=local                    # or 'ic' for mainnet
DFX_VERSION=0.15.0

# GoHighLevel Integration
GHL_API_KEY=your_api_key
GHL_LOCATION_ID=your_location_id
GHL_WEBHOOK_SECRET=your_secret

# Development Settings
NODE_ENV=development
DEBUG=true
```

## 🧪 Testing

Run the comprehensive test suite:

```bash
# All tests
./scripts/test.sh

# Specific test types
./scripts/test.sh --unit           # Unit tests only
./scripts/test.sh --integration    # Integration tests only
./scripts/test.sh --coverage       # With coverage report
```

## 🚀 Deployment

### Local Development
```bash
./scripts/deploy.sh local
```

### Internet Computer Mainnet
```bash
./scripts/deploy.sh ic
```

## 💬 Usage Examples

### Basic Commands
```
"Show me recent contacts"
"Create a new workflow for lead nurturing"
"Update the Smith opportunity to won"
"Schedule an appointment for tomorrow at 2 PM"
```

### Advanced Automation
```
"When a new contact is created, add them to the welcome workflow and send an SMS"
"If an opportunity value exceeds $10,000, notify the sales manager"
"Generate a weekly report of conversion rates by source"
```

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

### Documentation
- [API Documentation](docs/API.md)
- [Integration Guide](docs/GHL_INTEGRATION.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

---

**Built with ❤️ on the Internet Computer**

*Agent Adam - Making GoHighLevel smarter, one command at a time.*
