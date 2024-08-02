"use client";

import React, { useState } from "react";
import { formatEther } from "viem";
import { Address, AddressInput, BytesInput, IntegerInput } from "~~/components/scaffold-eth";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

const MultiSig = () => {
  const [addressTo, setAddressTo] = useState("");
  const [txValue, setTxValue] = useState<string | bigint>("");
  const [txByte, setTxByte] = useState("");

  const { writeContractAsync } = useScaffoldWriteContract("MultiSigWallet");
  async function submitTransaction() {
    await writeContractAsync({
      functionName: "submitTransaction",
      args: [addressTo, BigInt(txValue), txByte as `0x${string}`],
    });
  }
  const { data: txCount } = useScaffoldReadContract({
    contractName: "MultiSigWallet",
    functionName: "getTransactionCount",
  });

  const { data: transactions } = useScaffoldReadContract({
    contractName: "MultiSigWallet",
    functionName: "getAlltransactions",
  });

  return (
    <div className="p-4">
      <div>
        <h3>Total transaction {Number(txCount)}</h3>
      </div>
      <div className="flex gap-4">
        <div className=" text-center max-w-60 flex-1">
          <p>Create your Transaction</p>
          <div className="flex flex-col gap-3">
            {/* input fields  */}
            <AddressInput placeholder="to address" value={addressTo} onChange={setAddressTo} />
            <IntegerInput placeholder="amount " value={txValue} onChange={setTxValue} />
            <BytesInput placeholder="bytes data" value={txByte} onChange={setTxByte} />
            <button className="btn btn-sm  bg-blue-400 p " onClick={submitTransaction}>
              Submit transaction
            </button>
          </div>
        </div>
        <div
          className="flex-1
        "
        >
          <h3>All transactions</h3>
          {transactions && (
            <div className="flex gap-3 flex-wrap">
              {transactions.map((transaction, index) => (
                <div key={index} className="rounded bg-blue-400 shadow-sm p-2 text-white">
                  <p>
                    To: <Address address={transaction.to} />
                  </p>
                  <p>Value: {formatEther(transaction.value)}</p>
                  <button className="btn btn-sm">Confirm</button>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default MultiSig;
