# BoomPow (bPow)

[![License](https://img.shields.io/github/license/BananoCoin/boompow)](https://github.com/BananoCoin/boompow/blob/master/LICENSE) [![CI](https://github.com/BananoCoin/boompow/workflows/CI/badge.svg)](https://github.com/BananoCoin/boompow/actions?query=workflow%3ACI)

## Fork

This fork of [BananoCoin/boompow](https://github.com/BananoCoin/boompow) makes the project a [Nix Flake](https://nixos.wiki/wiki/Flakes).
The following things are provided by the Flake:

- `bpow-client` package
- `nano-work-server` package
- NixOS module to start both in systemd services

### Usage

Executing the `bpow-client` can be done like this:

```
$ nix run github:Deleh/boompow#bpow-client
```

The `nano-work-server` can be started like this:

```
$ nix run github:Deleh/boompow#nano-work-server
```

Additional command line arguments can be passed after two dashes:

```
$ nix run github:Deleh/boompow#bpow-client -- --help
```

The NixOS module can be used in a flake injected config like this:

```
inputs.boompow.url = github:Deleh/boompow;
outputs = { self, nixpks, boompow }: {
  nixosConfigurations.hostname = {
    ...

    modules = [
      boompow.nixosModule {
        walletAddress = "<your_banano_wallet_address>";
      };
    ];

    ...
  };
};
```

The following NixOS options are available:

- `cpuThreads`
  - Type: `int`
  - Default: `1`
  - Description: Specifies how many CPU threads to use. This option is only applied if 'mode' is set to 'cpu'.
- `gpuAddress`
  - Type: `str`
  - Default: `0:0`
  - Description: Specifies which GPU(s) to use in the form <PLATFORM:DEVICE:THREADS>... THREADS is optional and defaults to 1048576. This option is only applied if 'mode' is set to 'gpu'.
- `group`
  - Type: `str`
  - Default: `bpow`
  - Description: Group under which the BoomPow client and Nano work server run.
- `mode`
  - Type: Enum, either `cpu` or `gpu`
  - Default: `gpu`
  - Description: Run the Nano work server in CPU or GPU mode. Use the options 'gpuAddress' and 'cpuThreads' to configure the modes.
- `port`
  - Type: `int`
  - Default: `7000`
  - Description: Local port of the Nano work server.
- `user`
  - Type: `str`
  - Default: `bpow`
  - Description: User under which the BoomPow client and Nano work server run.
- `walletAddress`
  - Type: `str`
  - Default: `None`
  - Description: Banano wallet address which will receive the payments.
- `workType`
  - Type: Enum, one of `any`, `ondemand` or `precache`
  - Default: `any`
  - Description: Work type, one of 'any', 'ondemand' or 'precache'.

### NixOS

This is [BANANO](https://banano.cc)'s peel of the distributed proof of work ([DPoW](https://github.com/guilhermelawless/nano-dpow)) system created by the Nano community. Special thanks to [Guilherme Lawless](https://github.com/guilhermelawless), [James Coxon](https://github.com/jamescoxon), and everybody else who has worked on creating the DPoW system.

## What is It?

Banano transactions require a "proof of work" in order to be broadcasted and confirmed on the network. Basically you need to compute a series of random hashes until you find one that is "valid" (satisifies the difficulty equation). This serves as a replacement for a transaction fee.

## Why do I want BoomPow?

The proof of work required for a BANANO transasction can be calculated within a couple seconds on most modern computers. Which begs the question "why does it matter?"

1. There's applications that require large volumes of PoW, while an individual calculation can be acceptably fast - it is different when it's overloaded with hundreds of problems to solve all at the same time.
    * The [Graham TipBot](https://github.com/bbedward/Graham_Nano_Tip_Bot) has been among the biggest block producers on the NANO and BANANO networks for more than a year. Requiring tens of thousands of calculations every month.
    * The [Twitter and Telegram TipBots](https://github.com/mitche50/NanoTipBot) also calculate PoW for every transaction
    * [Kalium](https://kalium.banano.cc) and [Natrium](https://natrium.io) are two of the most widely used wallets on the NANO and BANANO networks with more than 10,000 users each. They all demand PoW whenever they make or send a transaction.
    * There's many other popular casinos, exchanges, and other applications that can benefit from a highly-available, highly-reliable PoW service.
2. While a single PoW (for BANANO) can be calculated fairly quickly on modern hardware, there are some scenarios in which sub-second PoW is highly desired.
    * [Kalium](https://kalium.banano.cc) and [Natrium](https://natrium.io) are the top wallets for BANANO and NANO. People use these wallets to showcase BANANO or NANO to their friends, to send money when they need to, they're used in promotional videos on YouTube, Twitter, and other platforms. *Fast* PoW is an absolute must for these services - the BoomPow system will provide incredibly fast proof of work from people who contribute using high-end hardware.

All of the aforementioned services will use the BoomPow system, and others services are free to request access as well.

## Who is Paying for this "High-End" Hardware?

[BANANO](https://banano.cc) is an instant, feeless, rich in potassium cryptocurrency. It has had an ongoing **free and fair** distribution since April 1st, 2018.

BANANO is distributed through [folding@home "mining"](https://bananominer.com), faucet games, giveaways, rain parties on telegram and discord, and more. We are always looking for new ways to distribute BANANO *fairly.*

BoomPow is going to reward contributors with BANANO. Similar to mining, if you provide valid PoW solutions for the BoomPow system you will get regular payments based on how much you contribute.

## Documentation

You can read more about the BoomPow [message specification](docs/specification.md).

## Running a work client

Read more on the [client documentation](client/README.md) page.

## Using BoomPow for your service

Read more on the [service documentation](service/README.md) page.

Please contact us on the BANANO [discord server](https://chat.banano.cc) for further assistance - use the channel #frankensteins-lab.

## Running your own server

Read more on the [server documentation](server/README.md) page.

We have made efforts to make it easier for anyone to run a BoomPow server for themselves. If you need any assistance, please use the [discord server](https://chat.banano.cc) or Github issues page.
