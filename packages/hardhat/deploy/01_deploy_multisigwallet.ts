import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

/**
 * Deploys a contract named "MultiSigWallet" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const numConfirmation = 2;
const owners = [
  "0xa88bc537277B2423686032a862FF8F8c67906168",
  "0x6924246628fC2E262161BABB288F780cec189A47",
  "0x2995cD31814f121b69FE2A51aaCf7A1C1CB74385",
];
const deployMultiSigWallet: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g `yarn deploy --network sepolia`), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with `yarn generate` which will fill DEPLOYER_PRIVATE_KEY
    with a random private key in the .env file (then used on hardhat.config.ts)
    You can run the `yarn account` command to check your balance in every network.
  */
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("MultiSigWallet", {
    from: deployer,
    // Contract constructor arguments
    args: [owners, numConfirmation],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });
};

export default deployMultiSigWallet;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags MultiSigWallet
deployMultiSigWallet.tags = ["multiSigWallet"];
