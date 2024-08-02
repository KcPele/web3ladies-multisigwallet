"use client";

import { useEffect, useState } from "react";
import { parseEther } from "viem";
import { useAccount } from "wagmi";
import { Address, InputBase, IntegerInput } from "~~/components/scaffold-eth";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

const Home = () => {
  const [greeting, setGreeting] = useState("");
  const [userName, setUserName] = useState("");
  const [age, setNewAge] = useState<string | bigint>("");

  const [updateName, setUpdateName] = useState("");
  const [updateUserAge, setUpdateUserAge] = useState<string | bigint>("");

  const { address: connectedAddress } = useAccount();
  const { data: greetings } = useScaffoldReadContract({
    contractName: "YourContract",
    functionName: "greeting",
  });

  const { data: totalCounter } = useScaffoldReadContract({
    contractName: "YourContract",
    functionName: "totalCounter",
  });

  const { writeContractAsync } = useScaffoldWriteContract("YourContract");

  const { data: totalUsers } = useScaffoldReadContract({
    contractName: "YourContract",
    functionName: "totalUsers",
  });

  const { data: premium } = useScaffoldReadContract({
    contractName: "YourContract",
    functionName: "premium",
  });
  const { data: getUser } = useScaffoldReadContract({
    contractName: "YourContract",
    functionName: "getUser",
    args: [connectedAddress],
  });

  const handleDeleteUser = async () => {
    try {
      await writeContractAsync({
        functionName: "deleteUser",
      });
    } catch (e) {
      console.log(e, "user is not deleted");
    }
  };

  const handleGreeting = async () => {
    try {
      const result = await writeContractAsync({
        functionName: "setGreeting",
        args: [greeting],
        value: parseEther("0.001"),
      });
      console.log(result);
    } catch (e) {
      console.error(e);
    }
  };
  useEffect(() => {
    if (getUser && getUser.userAddress === connectedAddress) {
      setUpdateName(getUser.name);
      setUpdateUserAge(getUser.age.toString());
    }
  }, [getUser]);
  return (
    <>
      <div className="flex  max-w-[1200px] gap-6 p-4 flex-grow pt-10">
        <div>
          {" "}
          <div className="px-5">
            <h1 className="text-center">
              <span className="block text-2xl mb-2">Welcome to</span>
              <span className="block text-4xl font-bold">Scaffold-ETH 2</span>
            </h1>
            <div className="flex justify-center items-center space-x-2 flex-col sm:flex-row">
              <p className="my-2 font-medium">Connected Address:</p>
              <Address address={connectedAddress} />
            </div>
          </div>
          <section>
            <h2 className="font-bold">Greeting from here: {greetings}</h2>
          </section>
          <section>
            <p>Read total counter:{Number(totalCounter)} </p>

            <div className="flex w-full flex-col gap-2">
              <InputBase value={userName} placeholder="john doe" onChange={setUserName} />
              <IntegerInput value={age} placeholder="20" onChange={setNewAge} />

              <button
                className=" bg-blue-300 rounded-lg text-center hover:bg-black hover:text-white"
                onClick={async () => {
                  try {
                    await writeContractAsync({
                      functionName: "createUser",
                      args: [userName, BigInt(age)],
                    });
                    setNewAge("");
                    setUserName("");
                  } catch (e) {
                    console.log("error here", e);
                  }
                }}
              >
                click me
              </button>
            </div>
          </section>
          <section>
            <p>Read total users:{Number(totalUsers)} </p>
          </section>
          <section className="flex flex-col gap-2">
            <div className="flex flex-col gap-2 items-center">
              <label>Greeting</label>
              <InputBase placeholder="type greeting" value={greeting} onChange={setGreeting} />
            </div>
            <button
              onClick={handleGreeting}
              className=" flex justify-center items-center bg-blue-500 w hover:bg-black hover:text-white rounded-lg"
            >
              New Greeting
            </button>
          </section>
        </div>
        <div>
          {/* July26 */}
          <h2>This user is {premium ? "on premium" : "not on premium"}</h2>
          <section>
            {/* BeeCodes  */}
            <button
              className="btn bg-white text-black border-1 border-gray-500 mb-5 rounded-lg hover:bg-black hover:text-white"
              onClick={handleDeleteUser}
            >
              {" "}
              deleted account
            </button>
          </section>
          <section className="fles justifty-center flex-col m-5">
            <h2>Display User</h2>
            {getUser && (
              <div>
                <p>Name: {getUser.name}</p>
                <p>Age: {Number(getUser.age)}</p>
              </div>
            )}

            <section>
              <h2>Update User</h2>
              <div className="flex w-full flex-col gap-2">
                <InputBase value={updateName} placeholder="john doe" onChange={setUpdateName} />
                <IntegerInput value={updateUserAge} placeholder="20" onChange={setUpdateUserAge} />

                <button
                  className=" bg-blue-300 rounded-lg text-center hover:bg-black hover:text-white"
                  onClick={async () => {
                    try {
                      await writeContractAsync({
                        functionName: "updateUser",
                        args: [updateName, BigInt(updateUserAge)],
                      });
                      setUpdateUserAge("");
                      setUpdateName("");
                    } catch (e) {
                      console.log("error here", e);
                    }
                  }}
                >
                  Update me
                </button>
              </div>
            </section>
          </section>
        </div>
      </div>
    </>
  );
};

export default Home;
