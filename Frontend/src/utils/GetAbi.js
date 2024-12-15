function getAbi(contractName, chainId) {
  const abi = require(`../Contract/deployments/chain-${chainId}/artifacts/${contractName}#${contractName}.json`);
  return abi;
}

export default getAbi;