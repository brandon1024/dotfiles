#!/usr/bin/env node

const path = require('path');
const readline = require('readline');
const fs = require('fs');
const { once } = require('events');

//Command-Line Argument Descriptions
const OPTIONS = [{
    short: 'f',
    long: 'file',
    argument: 'file',
    multiplicity: 1,
    description: 'Specify the input file'
}, {
    short: 'c',
    long: 'classify',
    description: 'Attempt to classify transactions into appropriate category'
}, {
    long: 'filter-debits',
    description: 'Filter any debit transactions'
}, {
    long: 'filter-credits',
    description: 'Filter any credit transactions'
}, {
    short: 'h',
    long: 'help',
    description: 'Show help and exit'
}];

//Transaction Category Classification Keywords
const CATEGORY_KEYWORDS = {
    groceries: ["SOBEYS", "SUPERSTORE", "SHOPPERS", "BULK BARN", "VICTORY MEAT", "BOUCLAIR", "COSTCO"],
    restaurant: ["DAIRY QUEEN", "THAI EXPRESS", "TIM HORTONS", "CHESS PIECE", "PATISSERIE", "BREWING", "GRAYSTONE",
        "GOJI'S", "YOGURT", "PIZZA", "RESTAURANT", "HILTON GARDEN", "CELLAR PUB", "KITCHEN", "MCDONALD'S",
        "TIPSY MUSE", "GAHAN", "HARVEY'S", "CORA", "BREAKFAST", "LUNCH", "FORESTRY COMP", "SUBWAY", "STARBUCKS",
        "RED ROVER", "PICAROONS", "HOME DEPOT", "POUTINERIE"],
    hair: ["AVALON", "SALONSPA"],
    rent: ["CEDAR VALLEY"],
    utilities: ["EnergieNB", "Power"],
    internet: ["BELL ALIANT"],
    memberships: ["Spotify", "Dollar Shave Club", "Prime Member"],
    fuel: ["CIRCLE K", "IRVING", "PETROCAN"],
    insurance: ["CO OPERATORS"],
    maintenance: ["SUTHERLAND", "HONDA"],
    registration: ["SERVICE NB"],
    accessories: ["RALLYE", "MOTOPLEX"],
    toll: [],
    su: ["PETSMART"],
    cell: [],
    clothing: [],
    financial_fees: ["Service Charge", "Overdrawn Handling", "SCOTIA SCCP PREMIUM"]
};

class Transaction {
    constructor(date, amount, description, raw) {
        this.date = date;
        this.amount = amount;
        this.description = description;
        this.raw = raw;
    }

    get currency() {
        return this.amount.toFixed(2);
    }

    toTableEntry() {
        return {
            date: this.date.toDateString(),
            amount: this.currency,
            details: this.description.join(' | ')
        };
    }

    toString() {
        return `${this.date.toDateString()} ${this.currency} ${this.description.join(' | ')}`;
    }

    static getTotalDeposits(transactions) {
        return transactions.filter(t => t.amount > 0)
            .map(t => t.amount)
            .reduce((partial_sum, a) => partial_sum + a, 0);
    }

    static getTotalWithdrawals(transactions) {
        return transactions.filter(t => t.amount <= 0)
            .map(t => t.amount)
            .reduce((partial_sum, a) => partial_sum + a, 0);
    }

    static getTotal(transactions) {
        return Transaction.getTotalDeposits(transactions) + Transaction.getTotalWithdrawals(transactions);
    }
}

/**
 * Parse the given array of command-line arguments.
 *
 * @param args An array of command-line arguments.
 * @return An object representing the arguments passed to this script.
 * */
function parseArgs(args) {
    let parsedArgs = {
        files: [],
        classify: false,
        help: false,
        error: []
    };

    for(let index = 2; index < args.length; index++) {
        switch(args[index]) {
            case "-f":
            case "--file":
                if (index+1 >= args.length) {
                    parsedArgs.error.push(`${args[index]} missing argument`);
                    return parsedArgs;
                }
                parsedArgs.files.push(args[++index]);
                break;
            case "-c":
            case "--classify":
                parsedArgs.classify = true;
                break;
            case "-h":
            case "--help":
                parsedArgs.help = true;
                break;
            default:
                parsedArgs.error.push(`unknown arg '${args[index]}'`);
                return parsedArgs;
        }
    }

    return parsedArgs;
}

/**
 * Show usage help, and optional error message.
 * */
function printHelp(error) {
    let synopsis = `usage: ${path.basename(process.argv[1])} [options]`;
    let description = `Parse and digest Scotiabank transaction file for consumption in other formats.\n`;
    let options = `options:\n`;

    for (const opt of OPTIONS) {
        if (opt.short && opt.long) {
            options = options.concat(`\t-${opt.short}, --${opt.long}`);
        } else if (opt.short) {
            options = options.concat(`\t-${opt.short}`);
        } else {
            options = options.concat(`\t--${opt.long}`);
        }

        if (opt.argument) {
            options = options.concat(` <${opt.argument}>`);
            if (opt.multiplicity > 1) {
                options = options.concat(`...`);
            }
        }

        options = options.concat(`\n\t\t${opt.description}\n`);
    }

    let parts = [synopsis, description, options];
    if (error) {
        console.error('\x1b[31m%s\x1b[0m', error.join(','));
    }

    console.log(parts.join('\n'));
}

/**
 * Parse a transaction file asynchronously. Transactions are read from the file and parsed into an array of
 * Transaction objects.
 * */
async function processFile(filepath) {
    const transactions = [];

    let reader = readline.createInterface({
        input: fs.createReadStream(filepath)
    });

    reader.on('line', line => {
        let transaction = new Transaction();
        transaction.raw = line;

        transaction.description = line.match(/".*?"/g).map(s => s.replace(/\s\s+/g, ' '));
        line = line.replace(/".*?"/g, '');

        //Split by comma and filter empty strings
        let cells = line.split(/,/).filter(cell => cell);

        transaction.date = new Date(cells[0]);
        transaction.amount = Number.parseFloat(cells[1]);

        transactions.push(transaction);
    });

    await once(reader, 'close');

    return transactions.sort((a, b) => {
        return a.date - b.date;
    });
}

parsedArgs = parseArgs(process.argv);
if (parsedArgs.error.length) {
    printHelp(parsedArgs.error);
    process.exit();
}

if (parsedArgs.help) {
    printHelp();
    process.exit();
}

if (parsedArgs.classify) {
    console.log("Transaction Classification:");

    parsedArgs.files.forEach(file => {
        processFile(file).then(transactions => {
            const categoryKeys = Object.keys(CATEGORY_KEYWORDS);
            let categories = {
                groceries: [], restaurant: [], hair: [],
                rent: [], utilities: [], internet: [], memberships: [],
                fuel: [], insurance: [], maintenance: [], registration: [], accessories: [], toll: [],
                su: [], cell: [], clothing: [], financial_fees: [],
                other: []
            };

            //For each transaction, compare against array of keywords to estimate the
            //category of the transaction.
            transactions.forEach(transaction => {
                let foundCategory = '';
                let ambiguous = false;

                categoryFound:
                for (const category of categoryKeys) {
                    nextCategory:
                    for (const keyword of CATEGORY_KEYWORDS[category]) {
                        for (const detail of transaction.description) {
                            if (!detail.toUpperCase().match(keyword.toUpperCase())) {
                                continue;
                            }

                            if (foundCategory) {
                                //if already found in another category, place into 'other' as it is an ambiguous transaction
                                ambiguous = true;
                                categories.other.push(transaction);
                                break categoryFound;
                            }

                            foundCategory = category;
                            break nextCategory;
                        }
                    }
                }

                if (foundCategory && !ambiguous) {
                    categories[foundCategory].push(transaction);
                } else {
                    categories.other.push(transaction);
                }
            });

            //print the categories
            const keys = Object.keys(categories);
            for (const category of keys) {
                if (!categories[category].length) {
                    continue;
                }

                console.group(`${category}: ${Transaction.getTotal(categories[category]).toFixed(2)}`);
                for (const t of categories[category]) {
                    console.log(t.toString());
                }

                console.groupEnd();
                console.log();
            }
        });
    });
} else {
    const COLUMN_HEADERS = ["date", "amount", "details"];

    console.log("Transaction Details:");

    parsedArgs.files.forEach(file => {
        processFile(file).then(transactions => {
            let tableData = transactions.map(t => t.toTableEntry());

            console.log(`\t${file}`);
            console.table(tableData, COLUMN_HEADERS);

            let deposits = Transaction.getTotalDeposits(transactions);
            let withdrawals = Transaction.getTotalWithdrawals(transactions);

            console.log(`Deposits: ${deposits.toFixed(2)}`);
            console.log(`Withdrawals: ${withdrawals.toFixed(2)}`);
            console.log(`Total Transactions: ${(deposits + withdrawals).toFixed(2)}`);
        });
    });
}
