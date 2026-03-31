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
        vm.startBroadcast();
        admin = new HashFitAdmin(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
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
        router = new PaidPurchaseRouter();
        keyRouter = new KeyPurchaseRouter();
        vm.stopBroadcast();
    }
}
