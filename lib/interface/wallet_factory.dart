import 'package:flutter_eoas/configuration/rpc_base_config.dart';
import 'package:flutter_eoas/eoa_wallet_manager.dart';

abstract class WalletFactory {
  Future<WalletManager> createWalletWithMnemonic(
      String mnemonic, ChainInformation configuration);
  Future<WalletManager> createWalletWithPrivateKey(String privateKey);
  Future<WalletManager?> createWalletWithGoogleClientId();
}
