const Web3 = require("web3");
const axios = require("axios");
const Interface = require("@ethersproject/abi").Interface;
const MulticallAbi = require("./abis/Multicall2.json").abi;
const CometAbi = require("./abis/Comet.json").abi;
const LiquidatorAbi = require("./abis/VanswapLiquidator.json").abi;
const keys = require("./keys.json");

process.env.NODE_TLS_REJECT_UNAUTHORIZED = 0;

/**
 * Execution process:
  1. Loop listen and update the global settings to get all supplycollateral users
  2. All users can check whether it can be liquidated
  3. Can be liquidated Perform flash loan liquidation, and sell collateral to keep the bonus in the liquidation contract
  4. Flash loan failure to manually perform liquidation, do not purchase collateral
  5. Collateral purchase
 * 
 * // https://vpioneer.infragrid.v.network/api/events/contract?logAddress=VMqsmgQBHXHZqy3Cv6sxnrjzU9YF4QGvUN&topic=fa56f7b24f17183d81894d3ac2ee654e3c26388d17a28dbd9549b8114304e1f4&count=true&limit=1000
 */

const pubKey = keys.PUBLIC_LIQ_VP;
const privateKey = keys.PRIVATE_LIQ_VP;
const comet_proxy_base58 = keys.COMET_BASE58;
const event_url = keys.VP_EVENT_URL;
const evm_compailable_rpc = keys.VP_EVM_RPC;

let comet_proxy = comet_proxy_base58;
let multicall2_addr_0x = keys.VP_MULTICALL_ADR;
let comet_proxy_0x = keys.VP_COMET_ADR;
let liquidator_contract_0x = keys.VP_LIQUIDATRO_ADR;


let start_ = 0;
let limit_ = 2000;
let count_ = true;

// event SupplyCollateral(address,address,address,uint256)
let topic_supply_collateral = "fa56f7b24f17183d81894d3ac2ee654e3c26388d17a28dbd9549b8114304e1f4";
const DATAWORD_PREFIX = '000000000000000000000000';

// let topic_url_vp = `https://vpioneer.infragrid.v.network/api/events/contract?logAddress=${comet_proxy}&topic=${topic_supply_collateral}&start=${start_}&limit=${limit_}&count+${count_}`;
let topic_url_vp_base = event_url;

var web3 = new Web3();
web3.setProvider(
    new Web3.providers.HttpProvider(
        evm_compailable_rpc
    )
);

let supplySet = new Set();
let multi = new web3.eth.Contract(MulticallAbi, multicall2_addr_0x);
let itf = new Interface(CometAbi); // Note that the ABI of the target contract is written here, which can be just one point

// Get addresses  through the HTTP interface
async function getSupplyAddress(_start) {
    if (_start > 0) {
        start_ = _start;
    }
    try {
        let resp = await axios({
            method: 'get',
            url: topic_url_vp_base,
            params: {
                logAddress: comet_proxy,
                topic: topic_supply_collateral,
                start: start_,
                limit: limit_,
                count: count_
            }
        });
        resp.data.data.map(msg => {
            supplySet.add(msg.log.topics[2])  // topic 0 is const，1 equals from maybe bulker，2 equals target
        })
        console.log("user who supply collaterals reackh %s times people", resp.data.total);
        return supplySet;
    } catch (error) {
        console.log("got user accure error. Retry...", error);
        await getSupplyAddress(start_);
    }

}

// build multic query params
function multiLiquidataAble(address) {
    const res = address.map((t) => ({
        address: comet_proxy_0x,
        name: "isLiquidatable",
        params: [t],
    }));
    return res;
}

async function mutilCometCall(calls) {
    const calldata = calls.map((call) => [
        call.address.toLowerCase(),
        itf.encodeFunctionData(call.name, call.params),
    ]);
    try {
        const { returnData } = await multi.methods.aggregate(calldata).call();
        // console.log("returnData . length = ", returnData.length)
        let res = returnData.map((call, i) =>
            itf.decodeFunctionResult(calls[i].name, call)
        );
        return res;
    } catch (error) {
        console.log("multicall execute failed, try again in next round", error)
    }
}


// full steps
async function getLiquidatableAddress() {
    // check liauidate able address
    start_ = 0;
    const myArr = []
    supplySet.forEach(ta => {
        myArr.push(ta.replace(DATAWORD_PREFIX, '0x'));
    })
    console.log("already find out %s addresses", myArr.length);
    let liquid_set = new Set();
    let slice = 100;
    let m = 0;

    const loop = async () => {
        let sliceArr = myArr.slice(m, m + slice);
        let calldata = multiLiquidataAble(sliceArr);
        let mutil_res = await mutilCometCall(calldata);
        console.log("check out result", mutil_res.length, calldata.length)
        if (mutil_res.length && mutil_res.length === sliceArr.length) {
            // note: await cannot use in foreach directly, use for await or recursion instead
            for (let i = 0; i < mutil_res.length; i++) {
                // console.log("================for mutil_res[i][0] = ", mutil_res[i][0]);
                if (mutil_res[i][0]) liquid_set.add(sliceArr[i]);
            }
        };
        m += slice;
        if (m < myArr.length) await loop();
    }

    await loop();

    console.log("here is the target can be liquidated", liquid_set);
    return Array.from(liquid_set);

}

// use flash swap to do absorb and buy collateral
async function doLiquidate(targets) {
    const liquidator = new web3.eth.Contract(LiquidatorAbi, liquidator_contract_0x);

    let data = liquidator.methods.initFlash(targets).encodeABI();
    const signedTx = await web3.eth.accounts.signTransaction(
        {
            to: liquidator_contract_0x,
            gas: 20000000000,
            data: data,
            gasPrice: 210000
        },
        privateKey
    );
    return await web3.eth.sendSignedTransaction(
        signedTx.rawTransaction || signedTx.rawTransaction
    );
}

// absorb only, leave collateral to protocol
async function do_absorb(targets) {
    const comet = new web3.eth.Contract(CometAbi, comet_proxy_0x);

    try {
        let data = comet.methods.absorb(pubKey, targets).encodeABI();
        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: liquidator_contract_0x,
                gas: 20000000000,
                data: data,
                gasPrice: 210000
            },
            privateKey
        );
        return await web3.eth.sendSignedTransaction(
            signedTx.rawTransaction || signedTx.rawTransaction
        );
    } catch (error) {
        console.log("absorb accure err, target is %s", targets);

    }

}

let timer = null;
let count = 0;
// start loop
async function loop(txcount) {
    try {
        console.log("already run bot %s minutes .....", txcount)
        // update user supply collateral every 5 minutes
        if (txcount % 5 == 0) {
            let supply_set = await getSupplyAddress(0);
            if (!supply_set) {
                console.log("here are %s address supply collateral success ....", supply_set.size);
            }

        }
        txcount++;
        let targets = await getLiquidatableAddress();

        if (targets.length > 0) {
            try {
                console.log("waiting for absorb.....", targets)
                doLiquidate(targets);
            } catch (error) {
                console.log("flash absorb failed, try do absorb only");
                do_absorb(targets);
            }
        } else {
            console.log("no target.....")
        }
        // 一分钟间隔
        timer = setTimeout(() => {
            loop(txcount);
        }, 60 * 1000);
    } catch (err) {
        console.error("this round accure err, start next loop.....", err);
        clearTimeout(timer);
        timer = setTimeout(() => {
            loop(txcount);
        }, 60 * 1000);
    }
}

async function listenExecute() {
    loop(count);
}

listenExecute();
