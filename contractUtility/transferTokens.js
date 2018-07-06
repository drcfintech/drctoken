#!/usr/bin/env node

// 'use strict';

// const validation = require("./validation.js");
// const log = require("./log/log.js");
// const timer = require("./timer.js");
// const responceData = require("./responceData.js")
// log.saveLog();
// const app = require('express')();
// const serverConfig = require('./config/serverConfig.json');
const path = require('path');
const http = require('http');
// 模块：对http请求所带的数据进行解析  https://www.cnblogs.com/whiteMu/p/5986297.html
const querystring = require('querystring');
const contract = require('truffle-contract');
const Web3 = require('web3');
// 解决Error：Web3ProviderEngine does not support synchronous requests
const Promise = require('bluebird');
// 生成钱包
//const HDWalletProvider = require("truffle-hdwallet-provider");
const walletConfig = require('./config/walletConfig.json');
// 签名之前构造rawTransaction用
var Tx = require('ethereumjs-tx');

const keystore = require(walletConfig.keystore);
//console.log('keystore  ', keystore);
// 用户操作
// const operation = ["getDepositAddr", "createDepositAddr", "withdraw", "withdrawTo", "freezeToken"];


// 智能合约
const DRCToken_artifacts = require('./build/contracts/DRCToken.json');
// 合约发布地址
const DRCToken_contractAT = DRCToken_artifacts.networks['4'].address;

// 合约abi
const DRCToken_contractABI = DRCToken_artifacts.abi;
// 初始化合约实例
let DRCTokenContract;
// 调用合约的账号
let account;

// 智能合约
const FlyDropToken_artifacts = require('./build/contracts/FlyDropToken.json');
// 合约发布地址
const FlyDropToken_contractAT = FlyDropToken_artifacts.networks['4'].address;

// 合约abi
const FlyDropToken_contractABI = FlyDropToken_artifacts.abi;
// 初始化合约实例
let FlyDropTokenContract;

// 智能合约
const ReleaseToken_artifacts = require('./build/contracts/ReleaseToken.json');
// 合约发布地址
const ReleaseToken_contractAT = ReleaseToken_artifacts.networks['4'].address;

// 合约abi
const ReleaseToken_contractABI = ReleaseToken_artifacts.abi;
// 初始化合约实例
let ReleaseTokenContract;

const readline = require('readline');
const fs = require("fs");

const filePath = process.argv[2];


// Add headers
// app.use((req, res, next) => {

//   req.setEncoding('utf8');
//   // Website you wish to allow to connect
//   res.setHeader('Access-Control-Allow-Origin', '*');

//   // Request methods you wish to allow
//   res.setHeader('Access-Control-Allow-Methods', 'GET, POST');

//   // Request headers you wish to allow
//   res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type');

//   // Set to true if you need the website to include cookies in the requests sent
//   // to the API (e.g. in case you use sessions)
//   res.setHeader('Access-Control-Allow-Credentials', false);

//   // Pass to next layer of middleware
//   next();
// });


// 新建initWeb3Provider连接
function initWeb3Provider() {

  if (typeof web3 !== 'undefined') {
    web3 = new Web3(web3.currentProvider);
  } else {
    web3 = new Web3(new Web3.providers.HttpProvider("https://rinkeby.infura.io/" + walletConfig.infuraAPIkey));
  }

  // 解决Error：TypeError: Cannot read property 'kdf' of undefined
  account = web3.eth.accounts.decrypt(JSON.parse(JSON.stringify(keystore).toLowerCase()), walletConfig.password);
  web3.eth.defaultAccount = account.address;
  console.log('web3.eth.defaultAccount : ', web3.eth.defaultAccount);

  if (typeof web3.eth.getAccountsPromise === 'undefined') {
    //console.log('解决 Error: Web3ProviderEngine does not support synchronous requests.');
    Promise.promisifyAll(web3.eth, {
      suffix: 'Promise'
    });
  }
}

// 初始化web3连接
initWeb3Provider();

let gasPrice;
let currentNonce = -1;

// 获取账户余额  警告 要大于 0.001Eth
const getBalance = (callback, dataObject = {}) => {
  web3.eth.getBalance(web3.eth.defaultAccount, (error, balance) => {
    if (error) {
      if (dataObject != {}) {
        dataObject.res.end(JSON.stringify(responceData.evmError));
      }
      // 保存log
      // log.saveLog(operation[1], new Date().toLocaleString(), qs.hash, 0, 0, responceData.evmError);
      return;
    }
    console.log('balance =>', balance);
    if (balance && web3.utils.fromWei(balance, "ether") < 0.001) {
      // 返回failed 附带message
      if (dataObject.res) {
        dataObject.res.end(JSON.stringify(responceData.lowBalance));
      }
      // 保存log
      // log.saveLog(operation[1], new Date().toLocaleString(), qs.hash, 0, 0, responceData.lowBalance);
      return;
    }
    callback(dataObject);
  });
}

// 获取data部分的nonce
const getNonce = () => {
  return new Promise((resolve, reject) => {
    const handle = setInterval(() => {
      web3.eth.getTransactionCount(web3.eth.defaultAccount, (error, result) => {
        if (error) {
          clearInterval(handle);
          reject(error);
        }
        if (result) {
          clearInterval(handle);
          console.log('current nonce is: ', currentNonce);
          console.log('current transaction count is: ', result);
          if (currentNonce < result) currentNonce = result;
          else currentNonce += 1;
          resolve(web3.utils.toHex(currentNonce)); // make sure the nonce is different
        }
      });
    }, 5000);
  })
  .catch(err => {
    console.log("catch error when getNonce");
    return new Promise.reject(err);
  });
}
  
// 获取data部分的gasPrice
const getGasPrice = () => {
  return new Promise((resolve, reject) => {
    const handle = setInterval(() => {
      web3.eth.getGasPrice((error, result) => {
        if (error) {
          clearInterval(handle);
          reject(error);
        }
        //resolve(web3.utils.toHex(result));
        if (result) {
          clearInterval(handle);
          
          gasPrice = web3.utils.fromWei(result, "gwei");
          console.log('gasPrice  ', gasPrice + 'gwei');
          if (gasPrice >= 3) result *= 1.25;
          else if (gasPrice >= 2) result *= 1.5;
          else result *= 2;
          
          resolve(web3.utils.toHex(result));
        }
      });
    }, 5000);
  })
  .catch(err => {
    console.log("catch error when getGasPrice");
    return new Promise.reject(err);
  });
};

// 给tx签名，并且发送上链
const sendTransaction = (rawTx) => {
  return new Promise((resolve, reject) => {
    let tx = new Tx(rawTx);

    // 解决 RangeError: private key length is invalid
    tx.sign(new Buffer(account.privateKey.slice(2), 'hex'));
    let serializedTx = tx.serialize();

    // a simple function to add the real gas Price to the receipt data
    let finalReceipt = (receipt) => {
      let res = receipt;
      res.gasPrice = rawTx.gasPrice;
      return res;
    }

    // 签好的tx发送到链上
    let txHash;
    web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'))
    .on('transactionHash', (hash) => {
      txHash = hash;
      console.log('TX hash: ', hash);
    })
    .on('receipt', (receipt) => {
      console.log('get receipt after send transaction: ', receipt);
      return resolve(finalReceipt(receipt));
    })
    .on('confirmation', (confirmationNumber, receipt) => {
    })
    .on('error', (err, receipt) => {
      console.error('catch an error after sendTransaction... ', err);
      if (err) {
        if (err.message.includes('not mined within 50 blocks')) {
          console.log("met error of not mined within 50 blocks...");
          if (receipt) {
            console.log('the real tx has already got the receipt: ', receipt);
            return resolve(finalReceipt(receipt));
          }

          // keep trying to get TX receipt
          const handle = setInterval(() => {
            web3.eth.getTransactionReceipt(txHash)
            .then((resp) => {
              if(resp != null && resp.blockNumber > 0) {
                console.log('get Tx receipt from error handling: ', resp);
                clearInterval(handle);
                return resolve(finalReceipt(resp));
              }
            })
            .catch(err => {
              console.log('met error when getting TX receipt from error handling');
              clearInterval(handle);
              reject(err);
            })
          }, 5000);
        
          // const TIME_OUT = 1800000; // 30 minutes timeout
          // setTimeout(() => {
          //   clearTimeout(handle);
          // }, TIME_OUT);
        } else if (err.message.includes('out of gas')) {
          console.error("account doesn't have enough gas...");
          console.log('TX receipt, ', receipt);
        }

        reject(err);
      }
    });
  })
  .catch(e => {
    console.error("catch error when sendTransaction");
    return new Promise.reject(e);
  });
};

let TxExecution = function(encodeData, resultCallback, dataObject = {}) {   

  // 上链结果响应到请求方
  // const returnResult = (result) => {
  //   resultCallback(result);        
  // }

  let callback = (dataObject) => {
    let returnObject = {};
    Promise.all([getNonce(), getGasPrice()])
      .then(values => {
        let rawTx = {
          nonce: values[0],
          to: contractAT,
          gasPrice: values[1],
          gasLimit: web3.utils.toHex(GAS_LIMIT),
          data: encodeData
        };
 
        gasPrice = web3.utils.fromWei(values[1], "gwei");
        return rawTx;
      })
      .then((rawTx) => {
        return sendTransaction(rawTx);
      })
      .then((result) => {
        // console.log("data object is ", dataObject);

        if (dataObject.res) {
          resultCallback(result, returnObject, dataObject);
        } else {
          resultCallback(result, returnObject);
        }
      })
      .catch(e => {
        if (e) {
          console.error('evm error', e);
          if(dataObject != {}) {
            dataObject.res.end(JSON.stringify(responceData.transactionError));
          }
          // 重置
          returnObject = {};
          // 保存log
          // log.saveLog(operation[1], new Date().toLocaleString(), qs.hash, gasPrice, 0, responceData.evmError);
          return;
        }
      });
  };

  getBalance(callback, dataObject);
};

var Actions = {
  // 初始化：拿到web3提供的地址， 利用json文件生成合约··
  start: function () {
    DRCTokenContract = new web3.eth.Contract(DRCToken_contractABI, DRCToken_contractAT, {});
    FlyDropTokenContract = new web3.eth.Contract(FlyDropToken_contractABI, FlyDropToken_contractAT, {});
    ReleaseTokenContract = new web3.eth.Contract(ReleaseToken_contractABI, ReleaseToken_contractAT, {});
    DRCTokenContract.setProvider(web3.currentProvider);
    FlyDropTokenContract.setProvider(web3.currentProvider);
    ReleaseTokenContract.setProvider(web3.currentProvider);
  },

  flydrop: function (filePath, dateStr) {
    console.log(DRCToken_contractAT);
    console.log(FlyDroptoken_contractAT);

    const tokenHolder = '0x3F14276Ea94C41D410Afd44e8F603810de414a5E';
    const ext = '.txt';
    let serial = 3;
    let order = 1;
    let flyDropFileName = 'addresses' + dateStr + '-' + serial + '-' + order + ext;
    let flyDropFile = filePath + flyDropFileName;
    console.log(flyDropFile);

    let i = 1;
    let flyDropAddresses;
    let flyDropValues;
    readline.createInterface({
      input: fs.createReadStream(flyDropFile)
    })
    .on('line', (line) => {
      console.log('Line from file:' + i + ":" + line);
      if (i == 1) {
        flyDropAddresses = line.split(',');
      }
      if (i == 2) {
        flyDropValues = line.split(',');
      }

      i += 1;
    });

    let encodeData_param = web3.eth.abi.encodeParameters(
      ['address', 'address[]', 'uint256[]'], 
      [tokenHolder, flyDropAddresses, flyDropValues]
    );
    
    console.log(encodeData_param);
    let encodeData_function = web3.eth.abi.encodeFunctionSignature('multiSendFrom(address,address[],uint256[])');
    console.log(encodeData_function);
    let encodeData = encodeData_function + encodeData_param.slice(2);
    console.log(encodeData);
  
    // let processResult = (result, returnObject) => {
    //   returnObject = {from: contractAT};
    //   returnObject.txHah = result.transactionHash;
    //   returnObject.gasUsed = result.gasUsed;
    //   returnObject.gasPrice = result.gasPrice;
    //   console.log('Transaction Result: ', returnObject);
  
      // logObject = result.logs[0];
      // console.log('result log: ', logObject);
  
      // 重置
      // returnObject = {};
      // 保存log
      // log.saveLog(operation[0], new Date().toLocaleString(), qs.hash, gasPrice, result.gasUsed, responceData.createDepositAddrSuccess);
    // };
  
    // TxExecution(encodeData, processResult);    
  }
};

Actions.start();
Actions.flydrop(filePath, '20180703');