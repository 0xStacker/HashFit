// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
import "forge-std/Test.sol";
import {HashFitAdmin} from "../src/HashFitAdmin.sol";
import {PaidPurchaseRouter} from "../src/routers/PaidPurchaseRouter.sol";
import {KeyPurchaseRouter} from "../src/routers/KeyPurchaseRouter.sol";
import {HashFitTypes} from "../src/Types.sol";
import {KeyBurner} from "../src/KeyBurner.sol";
import {MockUSDT} from "./MockUSDT.sol";
import {HashFitCore} from "../src/HashFit.sol";

contract HashFitCoreTest is Test {
    HashFitAdmin admin;
    MockUSDT usdt;
    PaidPurchaseRouter router;
    KeyPurchaseRouter keyRouter;
    address[2] wlUsers = [address(234), address(345)];
    bytes32 root = bytes32(0x9c8ddc6ab231bcd108eb0758933a2bb40bc8dad8fbae0261383da40014080906);
    bytes32[] proof;
    mapping(address => bytes32[]) proofs;

    function setUp() public {
        usdt = new MockUSDT();
        HashFitTypes.KeyDetail memory keyDetail = HashFitTypes.KeyDetail({validity: 0, generation: 0});

        HashFitTypes.Key memory mythic = HashFitTypes.Key({uri: "test/mythic", keyDetail: keyDetail});

        HashFitTypes.Key memory legendary = HashFitTypes.Key({uri: "test/legendary", keyDetail: keyDetail});

        HashFitTypes.Key memory epic = HashFitTypes.Key({uri: "test/epic", keyDetail: keyDetail});

        admin = new HashFitAdmin(HashFitTypes.FactorySetup({epic: epic, legendary: legendary, mythic: mythic}));

        router = new PaidPurchaseRouter();
        keyRouter = new KeyPurchaseRouter();
        proofs[wlUsers[0]].push(bytes32(0x1329b10cd9884c57ade41669fe693e126eb9b5236d94980d18cc92c1b5cae61f));
        proofs[wlUsers[1]].push(bytes32(0xad67874866783b4129c60d23995daac0c837c320b38a19d1915e7fa4586bcefc));
        proofs[wlUsers[1]].push(bytes32(0xf0718c9b19326d1812c0d459d3507b9122280148d3f90f4f3c97c0e6a9c946e5));
    }

    function testSetUp() public view {
        console.log(address(admin));
        console.log(address(router));
        console.log(address(admin.factory()));
    }

    struct ItemData {
        uint64 maxSupply;
        uint64 priceInKeys;
    }

    function constructDrop(ItemData memory data) internal view returns (HashFitTypes.HashFitDrop memory setup) {
        HashFitTypes.Item[] memory items = new HashFitTypes.Item[](3);

        HashFitTypes.Item memory item = HashFitTypes.Item({
            maxSupply: data.maxSupply,
            discount: 0,
            priceInKeys: data.priceInKeys,
            price: 100,
            name: "Shirt",
            uri: "test/shirt"
        });

        HashFitTypes.Item memory item1 = HashFitTypes.Item({
            maxSupply: data.maxSupply,
            discount: 0,
            priceInKeys: data.maxSupply,
            price: 50,
            name: "Short",
            uri: "test/short"
        });

        HashFitTypes.Item memory item2 = HashFitTypes.Item({
            maxSupply: data.maxSupply,
            discount: 0,
            priceInKeys: data.priceInKeys,
            price: 100,
            name: "Tank",
            uri: "test/tank"
        });

        items[0] = item;
        items[1] = item1;
        items[2] = item2;

        setup = HashFitTypes.HashFitDrop({
            generation: 0,
            saleStartTime: 0,
            cypheringPhaseDuration: 0,
            uri: "test/drop0",
            items: items,
            token: address(usdt)
        });
    }

    /// @dev Test proper contract deployments and setup
    function testDeployGenDrop() public {
        ItemData memory data = ItemData({maxSupply: 30, priceInKeys: 0});

        HashFitTypes.HashFitDrop memory setup = constructDrop(data);
        uint256 oldDropLength = admin.factory().genDrops().length;
        uint256 oldTotalDeployed = admin.totalDropsDeployed();
        admin.deployHashFitDrop(setup);
        uint256 newDropLength = admin.factory().genDrops().length;
        uint256 newTotalDeployed = admin.totalDropsDeployed();
        assertEq(newTotalDeployed, oldTotalDeployed + 1);
        assertEq(newDropLength, oldDropLength + 1);

        assertEq(admin.factory().genDrops()[newDropLength - 1].totalSupply(), 90);
        console.log(admin.factory().lastGen().items().length);
        console.log(admin.factory().genDrops()[newDropLength - 1].uri(0));
    }

    /// @dev Deploys both gen drop and exclusive drop simultaneously
    function testDeployParallelDrops() public {
        ItemData memory data = ItemData({maxSupply: 30, priceInKeys: 3});
        HashFitTypes.HashFitDrop memory setup = constructDrop(data);
        uint256 oldExclusiveLength = admin.factory().exclusiveDrops().length;
        admin.deployExclusiveDrop(root, setup);
        uint256 newExclusiveLength = admin.factory().exclusiveDrops().length;
        testDeployGenDrop();

        assertEq(newExclusiveLength, oldExclusiveLength + 1);
        assertEq(admin.factory().exclusiveDrops()[newExclusiveLength - 1].totalSupply(), 90);
    }

    //

    struct Item {
        address gen;
        HashFitTypes.SaleItem[] items;
        bytes32[] proof;
    }

    function constructPaidRouterInput(address gen, address user, uint64 purchaseAmount, bytes32[] memory _proof)
        internal
        returns (PaidPurchaseRouter.Item[] memory purchaseItems)
    {
        HashFitTypes.SaleItem[] memory items = new HashFitTypes.SaleItem[](2);

        HashFitTypes.SaleItem memory item = HashFitTypes.SaleItem({itemId: 0, amount: purchaseAmount});

        items[0] = item;

        HashFitTypes.SaleItem memory item1 = HashFitTypes.SaleItem({itemId: 1, amount: 5});
        items[1] = item1;

        PaidPurchaseRouter.Item memory purchaseItem = PaidPurchaseRouter.Item({gen: gen, items: items, proof: _proof});

        purchaseItems = new PaidPurchaseRouter.Item[](1);
        purchaseItems[0] = purchaseItem;
        vm.startPrank(user, user);
        for (uint256 i; i < purchaseItems.length; i++) {
            for (uint256 j; j < purchaseItems[i].items.length; j++) {
                usdt.mint(user, 1 ether);
                usdt.approve(purchaseItems[i].gen, type(uint256).max);
            }
        }
        vm.stopPrank();
    }

    function testPurchaseItemFromGenDrop() public {
        //  Gen 0
        testDeployGenDrop();
        // Gen 1
        testDeployGenDrop();
        PaidPurchaseRouter.Item[] memory purchaseItems =
            constructPaidRouterInput(address(admin.factory().genesis()), address(123), 3, proof);
        vm.startPrank(address(123), address(123));
        router.bundledPurchase(purchaseItems);
        vm.stopPrank();

        // for drop
        for (uint256 i; i < purchaseItems.length; i++) {
            // for item in drop
            for (uint256 j; j < purchaseItems[i].items.length; j++) {
                assertEq(
                    HashFitCore(purchaseItems[i].gen).itemsLeft(purchaseItems[i].items[j].itemId),
                    30 - purchaseItems[i].items[j].amount
                );
            }
        }
    }

    function testPurchaseFromExclusiveDropUsingGenDropRouter() public {
        testDeployParallelDrops();
        testDeployParallelDrops();
        address user = wlUsers[0];
        PaidPurchaseRouter.Item[] memory purchaseItems =
            constructPaidRouterInput(address(admin.factory().exclusiveDrops()[0]), user, 3, proofs[user]);
        vm.startPrank(user, user);
        router.bundledPurchase(purchaseItems);
        vm.stopPrank();
    }

    function testSetDiscountOnItem() public {
        testDeployGenDrop();
        // set 5% discount
        admin.setDiscount(0, 0, 500);
        PaidPurchaseRouter.Item[] memory purchaseItems =
            constructPaidRouterInput(address(admin.factory().genesis()), address(123), 3, proof);

        uint256 oldBal = usdt.balanceOf(address(123));
        vm.startPrank(address(123), address(123));
        router.bundledPurchase(purchaseItems);
        vm.stopPrank();
        // remove discount
        assertEq(usdt.balanceOf(address(123)), oldBal - 535);
        admin.setDiscount(0, 0, 0);
        oldBal = usdt.balanceOf(address(123));
        vm.startPrank(address(123), address(123));
        router.bundledPurchase(purchaseItems);
        vm.stopPrank();
        assertEq(usdt.balanceOf(address(123)), oldBal - 550);
    }

    function testRestockItems() public {
        testDeployGenDrop();
        PaidPurchaseRouter.Item[] memory purchaseItems =
            constructPaidRouterInput(address(admin.factory().genesis()), address(123), 3, proof);
        admin.restock(0, 0, 10);
        assertEq(admin.factory().genesis().totalSupply(), 100);
        assertEq(admin.factory().genesis().items()[0].maxSupply, 40);
        (uint64 maxSupply,,,,,) = admin.factory().genesis().dropItems(0);
        assertEq(maxSupply, 40);
        vm.startPrank(address(123), address(123));
        router.bundledPurchase(purchaseItems);
        vm.stopPrank();
        admin.restock(0, 0, 10);
        assertEq(admin.factory().genesis().totalSupply(), 110);
        (uint64 newmaxSupply,,,,,) = admin.factory().genesis().dropItems(0);
        assertEq(newmaxSupply, 50);
    }

    function testNonTransferability() public {
        testPurchaseItemFromGenDrop();

        HashFitCore drop = admin.factory().genesis();
        uint256 dropBal = drop.balanceOf(address(123), 0);
        assertEq(dropBal, 3);
        vm.prank(address(123));
        vm.expectRevert();
        drop.safeTransferFrom(address(123), address(admin), 0, 1, "");
        vm.expectRevert();
        drop.setApprovalForAll(address(admin), true);
        uint256[] memory ids = new uint256[](1);
        ids[0] = 0;
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 0;
        vm.expectRevert();
        drop.safeBatchTransferFrom(address(123), address(admin), ids, amounts, "");
    }

    function testDistributeKeys() public {
        testPurchaseItemFromGenDrop();
        HashFitTypes.Receiver memory user1 = HashFitTypes.Receiver({receiverAddress: address(123), amount: 1});

        HashFitTypes.Receiver[] memory users = new HashFitTypes.Receiver[](1);
        users[0] = user1;
        admin.distributeKeys(users, HashFitTypes.KeyTier.MYTHIC);
        admin.distributeKeys(users, HashFitTypes.KeyTier.LEGENDARY);
        admin.distributeKeys(users, HashFitTypes.KeyTier.EPIC);
        assertEq(admin.factory().mythic().balanceOf(address(123)), 1);
        assertEq(admin.factory().legendary().balanceOf(address(123)), 1);
        assertEq(admin.factory().epic().balanceOf(address(123)), 1);
    }

    function testPurchaseExclusiveItemWithKey() public {
        testDeployParallelDrops();
        HashFitTypes.Receiver memory user1 = HashFitTypes.Receiver({receiverAddress: address(123), amount: 3});

        HashFitTypes.Receiver[] memory users = new HashFitTypes.Receiver[](1);
        users[0] = user1;
        admin.distributeKeys(users, HashFitTypes.KeyTier.MYTHIC);
        HashFitTypes.SaleItem memory purchaseItem = HashFitTypes.SaleItem({itemId: 0, amount: 1});
        uint256[] memory keyIds = new uint256[](3);
        keyIds[0] = 1;
        keyIds[1] = 2;
        keyIds[2] = 3;
        KeyPurchaseRouter.Item memory routerInput = KeyPurchaseRouter.Item({
            gen: address(admin.factory().exclusiveDrops()[0]), item: purchaseItem, keyIds: keyIds
        });

        KeyPurchaseRouter.Item[] memory bundledItems = new KeyPurchaseRouter.Item[](1);
        bundledItems[0] = routerInput;
        assertEq(admin.factory().mythic().balanceOf(user1.receiverAddress), 3);
        vm.startPrank(user1.receiverAddress, user1.receiverAddress);
        admin.factory().mythic().setApprovalForAll(address(admin.factory().exclusiveDrops()[0]), true);
        vm.stopPrank();
        vm.expectRevert();
        keyRouter.bundledPurchase(bundledItems);
        vm.startPrank(user1.receiverAddress, user1.receiverAddress);
        keyRouter.bundledPurchase(bundledItems);
        vm.stopPrank();
        assertEq(admin.factory().exclusiveDrops()[0].balanceOf(user1.receiverAddress, 0), 1);
        // test incomplete key set

        routerInput.keyIds = new uint256[](1);
        bundledItems[0] = routerInput;
        vm.expectRevert();
        keyRouter.bundledPurchase(bundledItems);
        routerInput.keyIds = new uint256[](3);
        routerInput.item.amount = 40;
        bundledItems[0] = routerInput;
        vm.expectRevert();
        keyRouter.bundledPurchase(bundledItems);

        // Ensure all keys were burnt
        assertEq(admin.factory().mythic().balanceOf(user1.receiverAddress), 0);

        assertEq(admin.factory().mythic().balanceOf(address(admin.factory().keyBurner())), 0);
    }
}
