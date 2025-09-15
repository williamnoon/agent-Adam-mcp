# Agent Adam - Deployment Guide 🚀

## Overview

Agent Adam is now ready for deployment to the Internet Computer! This guide provides multiple deployment options ranging from quick testing to production deployment.

## ✅ Current Status

- **✅ Frontend**: Fully functional at `http://localhost:3000`
- **✅ Smart Contracts**: Complete Motoko implementation ready
- **✅ Tests**: All 9 tests passing
- **✅ Build System**: Configured and tested

## 🎯 Deployment Options

### Option 1: ICP Ninja (Quickest - Recommended for Testing)

**Best for**: Quick testing and demos
**Duration**: 20 minutes
**Cost**: Free

#### Steps:
1. Visit **ICP Ninja** at the Internet Computer website
2. Create a new project or import existing code
3. Copy/paste your Motoko files from `src/AgentAdam/`
4. Copy/paste your frontend files from `src/frontend/`
5. Click **Deploy**
6. Receive two URLs:
   - **Backend URL**: Candid interface for smart contract
   - **Frontend URL**: Live Agent Adam interface

#### Expected URLs:
```
Backend:  https://xxxxx-xxxxx-xxxxx-xxxxx-cai.icp1.io
Frontend: https://yyyyy-yyyyy-yyyyy-yyyyy-cai.icp1.io
```

### Option 2: DFX Playground (CLI Deployment)

**Best for**: Developers with DFX installed
**Duration**: 20 minutes
**Cost**: Free

#### Prerequisites:
- DFX installed and working
- Internet connection

#### Commands:
```bash
# Deploy to playground
dfx deploy --playground

# Get URLs
dfx canister --network playground call AgentAdam getCanisterStatus
```

### Option 3: GitHub Codespaces/Gitpod (Cloud Development)

**Best for**: Development and testing without local setup
**Duration**: As long as needed
**Cost**: Free tier available

#### GitHub Codespaces:
1. Fork this repository
2. Click "Code" → "Codespaces" → "Create codespace"
3. Wait for environment setup
4. Run: `dfx start --background`
5. Run: `dfx deploy --playground`

#### Gitpod:
1. Visit: `https://gitpod.io/#https://github.com/yourusername/agent-adam-mcp`
2. Wait for environment setup
3. Run deployment commands

### Option 4: Production Mainnet Deployment

**Best for**: Production use
**Duration**: Permanent
**Cost**: Requires cycles

#### Prerequisites:
- DFX installed
- ICP wallet with cycles
- Domain configured (optional)

#### Commands:
```bash
# Deploy to mainnet
dfx deploy --network ic

# Monitor deployment
dfx canister --network ic status AgentAdam
dfx canister --network ic status frontend
```

## 📋 Deployment Checklist

### Pre-Deployment
- [ ] All tests passing (`npm test`)
- [ ] Environment variables configured
- [ ] GoHighLevel integration settings ready

### During Deployment
- [ ] Backend canister deployed successfully
- [ ] Frontend canister deployed successfully
- [ ] Candid interface accessible
- [ ] Frontend loads without errors

### Post-Deployment
- [ ] Test basic functionality
- [ ] Configure GoHighLevel webhooks
- [ ] Test voice integration
- [ ] Test chat integration
- [ ] Monitor canister cycles (mainnet only)

## 🔧 Configuration

### Environment Variables
Update these in your deployment environment:

```env
# GoHighLevel Integration
GHL_API_KEY=your_api_key_here
GHL_LOCATION_ID=your_location_id_here
GHL_WEBHOOK_SECRET=your_webhook_secret_here

# Network Configuration
NETWORK=playground  # or 'ic' for mainnet
```

### GoHighLevel Webhook Setup

After deployment, configure these webhook URLs in GoHighLevel:

```
Webhook URL: https://your-backend-canister-id.ic0.app/webhook
Voice Agent: https://your-backend-canister-id.ic0.app/voice
Chat Integration: https://your-frontend-canister-id.ic0.app
```

## 🧪 Testing Deployed Application

### Backend Testing (Candid UI)
1. Visit backend URL
2. Test these methods:
   - `getCanisterStatus()` - Should return "Agent Adam is online"
   - `getTotalCommands()` - Should return 0 initially
   - `processAdminCommand(userId, locationId, instruction)`

### Frontend Testing
1. Visit frontend URL
2. Verify:
   - Chat interface loads
   - Quick actions work
   - Status shows "Online"
   - Input field accepts text

### Integration Testing
1. Send test webhook
2. Test voice command
3. Test chat message
4. Verify GHL integration

## 🚨 Troubleshooting

### Common Issues

**"Canister not found"**
- Check canister ID is correct
- Verify network (playground vs ic)
- Wait a few minutes for propagation

**"Module not found"**
- Ensure all dependencies in dfx.json
- Check Motoko imports
- Verify vessel.dhall

**"Frontend not loading"**
- Check asset canister deployed
- Verify CORS settings
- Check browser console for errors

**"DFX compatibility issues"**
- Use online IDE (Codespaces/Gitpod)
- Use ICP Ninja
- Try different DFX version

### Support Resources
- Internet Computer Documentation
- ICP Developer Discord
- GitHub Issues

## 📊 Monitoring

### Playground Deployments
- ⏰ 20-minute expiration timer
- 🔄 Redeploy as needed
- 📝 Save important test data

### Mainnet Deployments
- 💎 Monitor cycle balance
- 📈 Track usage metrics
- 🔍 Monitor error logs
- 🔄 Plan for upgrades

## 🎉 Success Criteria

Your deployment is successful when:

1. **Backend accessible**: Candid UI responds
2. **Frontend loads**: Agent Adam interface appears
3. **Status online**: Green indicator shows "Online"
4. **Basic commands work**: Can send and receive messages
5. **GHL integration ready**: Webhook endpoints respond

## 🔄 Next Steps After Deployment

1. **Configure GoHighLevel**:
   - Add webhook URLs
   - Set up voice agent integration
   - Configure chat mentions

2. **Test End-to-End**:
   - Send real GHL webhook
   - Test voice calls
   - Test chat interactions

3. **Monitor and Iterate**:
   - Watch for errors
   - Gather user feedback
   - Plan feature updates

---

**🤖 Agent Adam is ready to make GoHighLevel smarter!**

*For support, create an issue in this repository or consult the Internet Computer documentation.*