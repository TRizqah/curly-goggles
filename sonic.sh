#!/bin/bash

BOLD_BLUE='\033[1;34m'
NC='\033[0m'
echo
if ! command -v node &> /dev/null
then
    echo -e "${BOLD_BLUE}Node.js is not installed. Installing Node.js...${NC}"
    echo
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo -e "${BOLD_BLUE}Node.js is already installed.${NC}"
fi
echo
if ! command -v npm &> /dev/null
then
    echo -e "${BOLD_BLUE}npm is not installed. Installing npm...${NC}"
    echo
    sudo apt-get install -y npm
else
    echo -e "${BOLD_BLUE}npm is already installed.${NC}"
fi
echo
echo -e "${BOLD_BLUE}Creating project directory and navigating into it${NC}"
mkdir -p SonicBatchTx
cd SonicBatchTx
echo
echo -e "${BOLD_BLUE}Initializing a new Node.js project${NC}"
echo
npm init -y
echo
echo -e "${BOLD_BLUE}Installing required packages${NC}"
echo
npm install @solana/web3.js chalk bs58
echo
echo -e "${BOLD_BLUE}Prompting for private key${NC}"
echo
read -p "Enter your solana wallet private key: " privkey
echo
echo -e "${BOLD_BLUE}Creating the Node.js script file${NC}"
echo
cat << EOF > tnx.mjs
import web3 from "@solana/web3.js";
import chalk from "chalk";
import bs58 from "bs58";

const connection = new web3.Connection("https://api.testnet.v1.sonic.game/", 'confirmed');

const privkey = "$privkey";
const from = web3.Keypair.fromSecretKey(bs58.decode(privkey));
const to = web3.Keypair.generate();


// Array of 5 recipient addresses
const recipientAddresses = [
    "MJKqp326RZCHnAAbew9MDdui3iCKWco7fsK9sVuZTX2", 
    "52C9T2T7JRojtxumYnYZhyUmrN7kqzvCLc4Ksvjk7TxD", 
    "8BseXT9EtoEhBTKFFYkwTnjKSUZwhtmdKY2Jrj8j45Rt", 
    "9QgXqrgdbVU8KcpfskqJpAXKzbaYQJecgMAruSWoXDkM", 
    "GitYucwpNcg6Dx1Y15UQ9TQn8LZMX1uuqQNn8rXxEWNC"
];

(async () => {
    // Loop over each recipient address
    for (let recipient of recipientAddresses) {
        const toPublicKey = new web3.PublicKey(recipient);
        console.log(chalk.green('Sending transactions to address:'), toPublicKey.toString());

        // Create and send 20 transactions to the current recipient
        for (let i = 0; i < 20; i++) {
            const transaction = new web3.Transaction().add(
                web3.SystemProgram.transfer({
                    fromPubkey: from.publicKey,
                    toPubkey: toPublicKey,
                    lamports: web3.LAMPORTS_PER_SOL * 0.00001, // Amount to send (0.001 SOL)
                })
            );

            try {
                const signature = await web3.sendAndConfirmTransaction(
                    connection,
                    transaction,
                    [from]
                );
                console.log(chalk.blue('Tx hash :'), signature);
            } catch (error) {
                console.error(chalk.red('Error sending transaction:'), error);
            }

            const randomDelay = Math.floor(Math.random() * 3) + 1;
            await new Promise(resolve => setTimeout(resolve, randomDelay * 1000)); // Random delay between 1-3 seconds
        }
        console.log(chalk.yellow('Completed 20 transactions to:'), toPublicKey.toString());
    }
})();


EOF
echo
echo -e "${BOLD_BLUE}Executing the Node.js script${NC}"
echo
node tnx.mjs
echo
