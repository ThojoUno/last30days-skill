# Task 2.1: Explain Existing Code (Easy)

## Objective
Test the tool's ability to read and understand existing Bicep code.

## Setup
Ensure the tool has access to `modules/starter/spoke-vnet/` directory.

## Prompt

```
Look at the existing spoke VNet module in modules/starter/spoke-vnet/.

Explain:
1. How does this module handle VNet peering back to the hub?
2. What parameters are required for peering to work correctly?
3. How are routes configured to send traffic through the hub firewall?
4. Is there anything missing or that could be improved for enterprise use?
```

## Expected Response Should Cover
- The bidirectional peering configuration (spoke-to-hub and hub-to-spoke)
- Use of hub VNet ID, firewall private IP, and remote gateway settings
- Route table association with 0.0.0.0/0 -> Firewall
- Potential improvements (private DNS, diagnostic settings, etc.)

## Scoring Focus
- **Context Understanding**: Does it accurately read and interpret the code?
- **Explanation Quality**: Clear, accurate, helpful analysis?
- **Best Practices**: Does it identify gaps or anti-patterns?
