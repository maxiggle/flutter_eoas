# FLUTTER_EOAS

Flutter_Eoas is a wrap of the [web3dart](https://pub.dev/packages/web3dart) package. This is developed to help new developers integrate ethereum accounts into their flutter applications seamlessly.
No need to understand all the web3 jargons to get started.
This package primarily supports social authentication like: [google_sign](https://pub.dev/packages/google_sign_in) in for deterministic account creation. This way, users can have their ethereum accounts tied to the google accounts.

## Features

- ***Google sign_in:*** Sign in users using their google accounts.
- ***HD Wallets:*** Mnemonics generated by Bip39 is used to create hierarchical deterministic wallets.

## Getting started

### Installation
Add this to your dependency:

```sh
dependencies:
  flutter_eoas: ^1.0.0
```

### Usage

```dart
// Create from mnemonic
final wallet = await WalletManager.createWalletWithExistingCredentials(
  mnemonic: "your twelve word mnemonic phrase here",
  rpcUrl: "YOUR_RPC_URL"
);

// Create from private key
final wallet = await WalletManager.createWalletWithExistingCredentials(
  privateKey: "your-private-key",
  rpcUrl: "YOUR_RPC_URL"
);

// Create new wallet
final wallet = await WalletManager.createWalletWithExistingCredentials(
  rpcUrl: "YOUR_RPC_URL"
);
```

### Google sign-In integration
```dart
final wallet = await walletManager.createWalletWithGoogleClientId();
```

## Performing operations
```dart
// Get wallet address
final address = await wallet.getWalletAddress(credentials);

// Check balance
final balance = await wallet.getBalance();

// Get private key
final privateKey = await wallet.getPrivateKey();

// Get mnemonic
final mnemonic = await wallet.getMnemonic();

// Get seed
final seed = await wallet.getSeed();

// Get public key
final publicKey = await wallet.getPublicKey();
```

## Token Operations
Interact and query ERC20 tokens using the ```TokenService``` class like below:

```dart
// Initialize TokenService
final tokenService = TokenService(
  client: web3Client,
  contractAddress: "YOUR_CONTRACT_ADDRESS",
  credentials: wallet.getCredentials(),
  contractAbi: "YOUR_CONTRACT_ABI",
  contractName: "YOUR_CONTRACT_NAME"
);

// Claim tokens from contract
final claimTxHash = await tokenService.claimTokens();

// Check token balance
final tokenBalance = await tokenService.checkNonNativeBalance();
```

***Note:*** Token operations automatically handle gas estimation and include a 20% buffer for gas limits to ensure transaction success.

<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 

# FLUTTER_EOAS

Flutter_Eoas is a wrap of the [web3dart](https://pub.dev/packages/web3dart) package. This is developed to help new developers integrate ethereum accounts into their flutter applications seamlessly.
No need to understand all the web3 jargons to get started.
This package primarily supports social authentication like: [google_sign](https://pub.dev/packages/google_sign_in) in for deterministic account creation. This way, users can have their ethereum accounts tied to the google accounts.

## Features

- ***Google sign_in:*** Sign in users using their google accounts.
- ***HD Wallets:*** Mnemonics generated by Bip39 is used to create hierarchical deterministic wallets.

## Getting started

### Installation
Add this to your dependency:

```sh
dependencies:
  flutter_eoas: ^1.0.0
```

### Usage

```dart
// Create from mnemonic
final wallet = await WalletManager.createWalletWithExistingCredentials(
  mnemonic: "your twelve word mnemonic phrase here",
  rpcUrl: "YOUR_RPC_URL"
);

// Create from private key
final wallet = await WalletManager.createWalletWithExistingCredentials(
  privateKey: "your-private-key",
  rpcUrl: "YOUR_RPC_URL"
);

// Create new wallet
final wallet = await WalletManager.createWalletWithExistingCredentials(
  rpcUrl: "YOUR_RPC_URL"
);
```

### Google sign-In integration
```dart
final wallet = await walletManager.createWalletWithGoogleClientId();
```

## Performing operations
```dart
// Get wallet address
final address = await wallet.getWalletAddress(credentials);

// Check balance
final balance = await wallet.getBalance();

// Get private key
final privateKey = await wallet.getPrivateKey();

// Get mnemonic
final mnemonic = await wallet.getMnemonic();

// Get seed
final seed = await wallet.getSeed();

// Get public key
final publicKey = await wallet.getPublicKey();
```

## Token Operations
Interact and query ERC20 tokens using the ```TokenService``` class like below:

```dart
// Initialize TokenService
final tokenService = TokenService(
  client: web3Client,
  contractAddress: "YOUR_CONTRACT_ADDRESS",
  credentials: wallet.getCredentials(),
  contractAbi: "YOUR_CONTRACT_ABI",
  contractName: "YOUR_CONTRACT_NAME"
);

// Claim tokens from contract
final claimTxHash = await tokenService.claimTokens();

// Check token balance
final tokenBalance = await tokenService.checkNonNativeBalance();
```

***Note:*** Token operations automatically handle gas estimation and include a 20% buffer for gas limits to ensure transaction success.
