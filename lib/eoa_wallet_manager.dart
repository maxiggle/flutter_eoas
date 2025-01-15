import 'dart:developer';
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'constant/abis/scopes.dart';
import 'flutter_eoas.dart';
import 'exceptions/exceptions.dart';

class WalletManager implements WalletFactory {
  final EthPrivateKey _credentials;
  final Web3Client _client;

  WalletManager({
    required String mnemonic,
    required String privateKey,
    required EthPrivateKey credentials,
    Web3Client? client,
  })  : _credentials = credentials,
        _client = client ??
            Web3Client(ChainConfiguration.liskTestnet.rpcUrl, Client());

  /// Creates a [WalletManager] instance using the given mnemonic phrase or private key.
  ///
  /// If both [mnemonic] and [privateKey] are null, a new wallet is created.
  ///
  /// If [mnemonic] is given, the method takes a mnemonic phrase as a string argument
  /// and a [String] [rpcUrl] as a second argument. It returns a [Future<WalletManager>]
  /// that completes with a [WalletManager] instance created from the mnemonic phrase.
  ///
  /// If the mnemonic phrase is empty, the method throws a [WalletException].
  ///
  /// If the mnemonic phrase is invalid, the method throws a [WalletException].
  ///
  /// If [privateKey] is given, the method takes a private key as a string argument
  /// and a [String] [rpcUrl] as a second argument. It returns a [Future<WalletManager>]
  /// that completes with a [WalletManager] instance created from the private key.
  ///
  /// If the private key is empty, the method throws a [WalletException].
  ///
  /// Returns a [Future<WalletManager>] that completes with the [WalletManager] instance
  /// created from the mnemonic phrase or private key.
  static Future<WalletManager> createWalletWithExistingCredentials({
    String? mnemonic,
    String? privateKey,
    required String rpcUrl,
  }) async {
    try {
      if (rpcUrl.isEmpty) {
        throw WalletException('RPC URL cannot be empty');
      }

      final client = Web3Client(rpcUrl, Client());

      if (mnemonic != null) {
        if (!bip39.validateMnemonic(mnemonic)) {
          throw WalletException('Invalid mnemonic phrase');
        }
        return await EOAWalletHelpers.fromMnemonic(mnemonic);
      } else if (privateKey != null) {
        if (!privateKey.startsWith('0x')) {
          privateKey = '0x$privateKey';
        }
        return await EOAWalletHelpers.fromPrivateKey(privateKey);
      } else {
        return await _createNewWallet(client);
      }
    } catch (e) {
      if (e is WalletException) rethrow;
      throw WalletException('Failed to create wallet', e);
    }
  }

  EthPrivateKey getCredentials() => _credentials;

  static Future<WalletManager> _createNewWallet(Web3Client client) async {
    try {
      final mnemonic = bip39.generateMnemonic();
      return await EOAWalletHelpers.fromMnemonic(mnemonic);
    } catch (e) {
      throw WalletException('Failed to create new wallet', e);
    }
  }

  @override

  /// Creates a `WalletManager` instance using a Google Client ID.
  ///
  /// This method utilizes Google Sign-In to authenticate the user and generate
  /// a mnemonic phrase based on the Google ID or the provided client ID. It attempts
  /// to create a wallet using this mnemonic phrase, returning a `WalletManager`
  /// instance if successful, or `null` if user authentication fails.
  ///
  /// If a `clientId` is provided, it is used to generate the mnemonic and create
  /// the wallet. Otherwise, Google Sign-In is used to obtain the ID from the
  /// authenticated Google user.
  ///
  /// If an error occurs during the process, a `WalletException` is thrown,
  /// and the user is signed out from Google.
  ///
  /// Returns a [Future<WalletManager?>] that completes with the created
  /// `WalletManager` instance or `null`.

  Future<WalletManager?> createWalletWithGoogleClientId(
      {String? clientId}) async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: scopes,
    );
    GoogleSignInAccount? googleUser;
    WalletManager? walletManager;
    try {
      if (clientId == null) {
        googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;
        await googleUser.authentication;
        final mnemonic = await _generateWallet(googleUser.id);
        log('generated Mnemonic: $mnemonic');
        walletManager = await EOAWalletHelpers.fromMnemonic(mnemonic);
      } else {
        final mnemonic = await _generateWallet(clientId);
        log('generated Mnemonic: $mnemonic');
        walletManager = await EOAWalletHelpers.fromMnemonic(mnemonic);
        final credentials = walletManager.getCredentials();
        log('generated Mnemonic: $mnemonic');
        final walletAddress = await walletManager.getWalletAddress(credentials);
        log('generated Wallet Address: $walletAddress');
      }

      return walletManager;
    } catch (e) {
      if (e is WalletException) {
        rethrow;
      }
      await googleSignIn.signOut();
      rethrow;
    }
  }

  /// Generates a mnemonic phrase based on the given Google ID for deterministic generation.
  ///
  /// The method takes a Google ID as a string argument and returns a [Future<String>] that completes with a mnemonic phrase.
  ///
  /// The mnemonic phrase is generated using the [EOAWalletHelpers.generateMnemonic] method.
  ///
  /// Returns a [Future<String>] that completes with the generated mnemonic phrase.
  Future<String> _generateWallet(String googleId) async {
    final seed = EOAWalletHelpers.generateMnemonic(googleId);
    return seed;
  }

  @override

  /// Creates a [WalletManager] instance using the given mnemonic phrase.
  ///
  /// The method takes a mnemonic phrase as a string argument and a [ChainInformation] object as a second argument.
  /// It returns a [Future<WalletManager>] that completes with a [WalletManager] instance created from the mnemonic phrase.
  ///
  /// If the mnemonic phrase is empty, the method throws a [WalletException].
  ///
  /// If the mnemonic phrase is invalid, the method throws a [WalletException].
  ///
  /// Returns a [Future<WalletManager>] that completes with the [WalletManager] instance created from the mnemonic phrase.
  Future<WalletManager> createWalletWithMnemonic(
      String mnemonic, ChainInformation configuration) async {
    try {
      final Web3Client client = Web3Client(configuration.rpcUrl, Client());

      if (mnemonic.trim().isEmpty) {
        return await _createNewWallet(client);
      }

      if (!bip39.validateMnemonic(mnemonic)) {
        throw WalletException('Invalid mnemonic phrase');
      }

      return await EOAWalletHelpers.fromMnemonic(mnemonic);
    } catch (e) {
      if (e is WalletException) {
        rethrow;
      }
      throw WalletException('Failed to create wallet: ${e.toString()}');
    }
  }

  @override

  /// Creates a [WalletManager] instance using the given private key.
  ///
  /// The method takes a private key as a string argument and returns a [Future<WalletManager>] that completes with a [WalletManager]
  /// instance created from the private key.
  ///
  /// If the private key is empty, the method throws a [WalletException].
  ///
  /// Returns a [Future<WalletManager>] that completes with the [WalletManager] instance created from the private key.
  Future<WalletManager> createWalletWithPrivateKey(String privateKey) async {
    if (privateKey.isEmpty) {
      throw WalletException('Private key cannot be empty');
    }
    return await EOAWalletHelpers.fromPrivateKey(
      privateKey,
    );
  }

  /// Returns the Ethereum address associated with the private key of the wallet as a hex string.
  ///
  /// The method takes the private key as an argument and returns the Ethereum address derived from it as a hex string.
  /// This address can be used to send Ether to the wallet, or for other wallet management tasks.
  ///
  /// Returns a [Future<String>] that completes with the string representation of the Ethereum address in hex.
  Future<String> getWalletAddress(EthPrivateKey credentials) async {
    final address = credentials.address;
    return address.hex;
  }

  /// Retrieves the balance of the wallet in Ether as a string.
  ///
  /// The method gets the balance of the wallet's Ethereum address and
  /// converts it to a string representation in Ether units, with 6 decimal
  /// places. This balance can be used to display the wallet's current balance
  /// or for other wallet management tasks.
  ///
  /// Returns a [Future<String>] that completes with the string representation
  /// of the balance in Ether.
  Future<String> getBalance() async {
    final address = _credentials.address;
    final balance = await _client.getBalance(address);
    final ethBalance = balance.getValueInUnit(EtherUnit.ether);
    return ethBalance.toStringAsFixed(6);
  }

  /// Returns the private key associated with the wallet's credentials as a string.
  ///
  /// The method retrieves the private key from the wallet's credentials and
  /// converts it to a string representation. This private key can be used for
  /// cryptographic operations or wallet management tasks.
  ///
  /// Returns a [Future<String>] that completes with the string representation
  /// of the private key.

  Future<String> getPrivateKey() async {
    return _credentials.privateKeyInt.toString();
  }

  /// Retrieves and returns the mnemonic phrase associated with the wallet.
  ///
  /// The method first extracts the private key from the wallet's credentials
  /// and then converts it to a mnemonic phrase using the BIP39 standard.
  ///
  /// Returns a [Future<String>] that completes with the mnemonic phrase.
  /// Throws a [WalletException] if the mnemonic cannot be retrieved or converted.
  Future<String> getMnemonic() async {
    return bip39.entropyToMnemonic(_credentials.privateKeyInt.toString());
  }

  /// Generates and returns the seed derived from the wallet's mnemonic phrase.
  ///
  /// The method first retrieves the mnemonic associated with the wallet and
  /// then converts it to a seed using the BIP39 standard. The seed is encoded
  /// as a hex string.
  ///
  /// Returns a [Future<String>] that completes with the hex-encoded seed.
  /// Throws a [WalletException] if the mnemonic cannot be retrieved or converted.

  Future<String> getSeed() async {
    final mnemonic = await getMnemonic();
    return hex.encode(bip39.mnemonicToSeed(mnemonic));
  }

  /// Returns the public key associated with the private key of the wallet as a hex string.
  ///
  /// Throws a [WalletException] if the public key cannot be derived from the private key.
  Future<String> getPublicKey() async {
    try {
      return _credentials.address.hex;
    } catch (e) {
      throw WalletException('Failed to derive public key', e);
    }
  }

  /// Signs a message with a private key and returns the signature as a hex string.
  ///
  /// The signature is the ECDSA signature of the message, using the private key.
  /// The signature is returned as a hex string, which can be used to verify the
  /// message on the Ethereum blockchain.
  ///
  /// The message is signed using the personal message scheme, which means that
  /// the message is hashed using the Ethereum-specific hash function, and the
  /// hash is then signed using the private key.
  ///
  /// This method is used to sign messages that are sent to smart contracts, and
  /// is not intended for use with external messages.
  ///
  /// The method throws a [WalletException] if the message cannot be signed.
  Future<String> signMessage(String message, EthPrivateKey credentials) async {
    try {
      final bytes = Uint8List.fromList(message.codeUnits);
      final signature = credentials.signPersonalMessageToUint8List(bytes);
      return hex.encode(signature);
    } catch (e) {
      throw WalletException('Failed to sign message', e);
    }
  }

  Future<MsgSignature> signMessageToEcSignature(
      String message, EthPrivateKey credentials) async {
    final bytes = Uint8List.fromList(message.codeUnits);
    return credentials.signToEcSignature(bytes);
  }

  Future<Uint8List> signMessageToBytes(
      String message, EthPrivateKey credentials) async {
    final bytes = Uint8List.fromList(message.codeUnits);
    return credentials.signToUint8List(bytes);
  }

  /// Signs a personal message with a private key and returns the signature as a hex string.
  ///
  /// The message is signed using the personal message scheme, which means that
  /// the message is hashed using the Ethereum-specific hash function, and the
  /// hash is then signed using the private key.
  ///
  /// The method throws a [WalletException] if the message cannot be signed.
  ///
  Future<String> signPersonalMessage(
      String message, EthPrivateKey credentials) async {
    final bytes = Uint8List.fromList(message.codeUnits);
    final signature = credentials.signPersonalMessageToUint8List(bytes);
    return hex.encode(signature);
  }

  /// Signs a message and returns detailed signature components
  /// Use this for smart contract interactions requiring r, s, v values
  Future<MsgSignature> signMessageForContract(
      String message, EthPrivateKey credentials) async {
    try {
      final bytes = Uint8List.fromList(message.codeUnits);
      return credentials.signToEcSignature(bytes);
    } catch (e) {
      throw WalletException('Failed to sign message for contract', e);
    }
  }

  Future<String> sendEth(String fromAddress, String toAddress, double amount,
      String privateKey) async {
    try {
      final credentials = EthPrivateKey.fromHex(privateKey);
      final credentialsAddress = credentials.address;

      if (credentialsAddress.hexEip55.toLowerCase() !=
          fromAddress.toLowerCase()) {
        throw WalletException('Private key does not match fromAddress.\n'
            'Derived address: ${credentialsAddress.hexEip55}\n'
            'FromAddress: $fromAddress');
      }
      final sender = EthereumAddress.fromHex(fromAddress);
      final recipient = EthereumAddress.fromHex(toAddress);
      final nonce = await _client.getTransactionCount(sender);
      final weiAmount = BigInt.from(amount * 1e18);
      final gasPrice = EtherAmount.inWei(BigInt.from(41000000000));
      final gasLimit = BigInt.from(21000);
      final transaction = await _client.sendTransaction(
        credentials,
        Transaction(
          from: sender,
          to: recipient,
          value: EtherAmount.inWei(weiAmount),
          maxGas: gasLimit.toInt(),
          gasPrice: gasPrice,
          nonce: nonce,
        ),
        chainId: 4202,
      );

      return transaction;
    } catch (e) {
      log('Error sending ETH: $e');
      throw Exception('Failed to send ETH: $e');
    }
  }
}

String privateZero() {
  return '0x0000000000000000000000000000000000000000000000000000000000000000';
}
