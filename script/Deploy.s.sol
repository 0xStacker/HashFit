// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "forge-std/Test.sol";
import {HashFitAdmin} from "../src/HashFitAdmin.sol";
import {PaidPurchaseRouter} from "../src/routers/PaidPurchaseRouter.sol";
import {KeyPurchaseRouter} from "../src/routers/KeyPurchaseRouter.sol";
import {HashFitTypes} from "../src/Types.sol";
import {HashFitMythic, HashFitLegendary, HashFitEpic} from "../src/HashFitKeys.sol";
import {KeyBurner} from "../src/KeyBurner.sol";
import {MockUSDT} from "../test/MockUSDT.sol";
import {HashFitCore} from "../src/HashFit.sol";
import {HashFitFactory} from "../src/factory/HashFitFactory.sol";
import {GenDropDeployer} from "../src/factory/GenDropDeployer.sol";
import {ExclusiveDropDeployer} from "../src/factory/ExclusiveDropDeployer.sol";

contract Deploy is Test {
    //
    // Admin contract
    HashFitAdmin admin;
    // Mock usdt for purchase
    MockUSDT usdt;
    PaidPurchaseRouter router;
    KeyPurchaseRouter keyRouter;

    struct ItemData {
        uint64 maxSupply;
        uint64 priceInKeys;
    }

    function run() public {
        HashFitTypes.KeyDetail memory keyDetail = HashFitTypes.KeyDetail({
            validity: 0,
            generation: 0
        });

        HashFitTypes.Key memory _mythic = HashFitTypes.Key({
            uri: "test/mythic",
            keyDetail: keyDetail
        });

        HashFitTypes.Key memory _legendary = HashFitTypes.Key({
            uri: "test/legendary",
            keyDetail: keyDetail
        });

        HashFitTypes.Key memory _epic = HashFitTypes.Key({
            uri: "test/epic",
            keyDetail: keyDetail
        });

        HashFitTypes.Receiver memory user1 = HashFitTypes.Receiver({
            receiverAddress: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            amount: 3
        });
        vm.startBroadcast();
        usdt = new MockUSDT();
        usdt.mint(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, 500 ether);
        admin = new HashFitAdmin(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
        address mythic = address(
            new HashFitMythic(_mythic.uri, _mythic.keyDetail, address(admin))
        );
        address legendary = address(
            new HashFitLegendary(
                _legendary.uri,
                _legendary.keyDetail,
                address(admin)
            )
        );
        address epic = address(
            new HashFitEpic(_epic.uri, _epic.keyDetail, address(admin))
        );

        HashFitFactory.Keys memory keys = HashFitFactory.Keys({
            mythic: mythic,
            epic: epic,
            legendary: legendary
        });

        admin.initializeFactory(keys);
        address genDeployer = address(
            new GenDropDeployer(address(admin.factory()), address(admin))
        );
        address exclusiveDropDeployer = address(
            new ExclusiveDropDeployer(address(admin.factory()), address(admin))
        );

        HashFitFactory.Deployers memory deployers = HashFitFactory.Deployers({
            genDropDeployer: genDeployer,
            exclusiveDropDeployer: exclusiveDropDeployer
        });
        admin.initializeFactoryDeployers(deployers);
        router = new PaidPurchaseRouter(
            0x70997970C51812dc3A010C7d01b50e0d17dc79C8,
            address(usdt)
        );
        keyRouter = new KeyPurchaseRouter(admin.factory().keyBurner(), mythic);

        HashFitTypes.Receiver[] memory users = new HashFitTypes.Receiver[](1);
        users[0] = user1;
        admin.distributeKeys(users, HashFitTypes.KeyTier.MYTHIC);
        admin.distributeKeys(users, HashFitTypes.KeyTier.LEGENDARY);
        vm.stopBroadcast();

        ItemData memory data = ItemData({maxSupply: 5, priceInKeys: 1});
        HashFitTypes.HashFitDrop memory setup = constructDrop(data);
        vm.startBroadcast();
        admin.deployExclusiveDrop(bytes32(0), setup);
        vm.stopBroadcast();
        testDeployGenDrop();

        console.log("mythic: ", mythic);
        console.log("Legendary: ", legendary);
        console.log("Router: ", address(router));
        console.log("Usdt: ", address(usdt));
        console.log("admin: ", address(admin));
        console.log("Key router: ", address(keyRouter));
        console.log("Factory: ", address(admin.factory()));
        console.log("Genesis", address(admin.factory().genesis()));
        console.log("Exclusive", address(admin.factory().exclusiveDrops()[0]));
    }

    function constructDrop(
        ItemData memory data
    ) internal view returns (HashFitTypes.HashFitDrop memory setup) {
        HashFitTypes.Item[] memory items = new HashFitTypes.Item[](5);

        HashFitTypes.Item memory item = HashFitTypes.Item({
            maxSupply: data.maxSupply,
            discount: 0,
            priceInKeys: data.priceInKeys,
            price: 25 ether,
            name: "Genesis M-50",
            uri: "/assests/background/bg3"
        });

        HashFitTypes.Item memory item1 = HashFitTypes.Item({
            maxSupply: data.maxSupply,
            discount: 0,
            priceInKeys: data.priceInKeys,
            price: 25 ether,
            name: "Genesis M-10",
            uri: "/assests/background/bg2"
        });

        HashFitTypes.Item memory item2 = HashFitTypes.Item({
            maxSupply: data.maxSupply,
            discount: 0,
            priceInKeys: data.priceInKeys,
            price: 100 ether,
            name: "Cypher-X",
            uri: "/assests/background/bg1"
        });

        HashFitTypes.Item memory item3 = HashFitTypes.Item({
            maxSupply: data.maxSupply,
            discount: 0,
            priceInKeys: data.priceInKeys,
            price: 25 ether,
            name: "Genesis M-1",
            uri: "/assests/background/bg1"
        });

        HashFitTypes.Item memory item4 = HashFitTypes.Item({
            maxSupply: data.maxSupply,
            discount: 0,
            priceInKeys: data.priceInKeys,
            price: 25 ether,
            name: "Genesis M-10",
            uri: "/assests/background/bg1"
        });

        items[0] = item;
        items[1] = item1;
        items[2] = item2;
        items[3] = item3;
        items[4] = item4;

        HashFitTypes.Routers memory routers = HashFitTypes.Routers({
            paidRouter: address(router),
            keyRouter: address(keyRouter)
        });

        setup = HashFitTypes.HashFitDrop({
            generation: 0,
            saleStartTime: 0,
            cypheringPhaseDuration: 0,
            uri: "/assests/background/cp2.png",
            items: items,
            token: address(usdt),
            routers: routers,
            name: "Genesis",
            symbol: "GENESIS"
        });
    }

    /// @dev Test proper contract deployments and setup
    function testDeployGenDrop() internal {
        ItemData memory data = ItemData({maxSupply: 30, priceInKeys: 0});
        HashFitTypes.HashFitDrop memory setup = constructDrop(data);
        vm.startBroadcast();
        admin.deployHashFitDrop(setup);
        vm.stopBroadcast();
    }
}
