import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-foundry";
import "dotenv-defaults/config";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [{ version: "0.8.23" }],
  },
  networks: {
    hardhat: {
      forking: {
        enabled: false,
        url: ``,
      },
    },
  },
};

export default config;
