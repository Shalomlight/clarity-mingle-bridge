import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create a new event",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const futureDate = chain.blockHeight + 100;
    
    let block = chain.mineBlock([
      Tx.contractCall('mingle-bridge', 'create-event',
        [
          types.ascii("Beach Party"),
          types.ascii("Summer fun!"),
          types.uint(futureDate),
          types.principal(deployer.address),
          types.uint(100)
        ],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
  }
});

Clarinet.test({
  name: "Can RSVP to an event",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const user1 = accounts.get('wallet_1')!;
    const futureDate = chain.blockHeight + 100;
    
    // First create an event
    let block = chain.mineBlock([
      Tx.contractCall('mingle-bridge', 'create-event',
        [
          types.ascii("Beach Party"),
          types.ascii("Summer fun!"),
          types.uint(futureDate),
          types.principal(deployer.address),
          types.uint(100)
        ],
        deployer.address
      )
    ]);
    
    // Then RSVP to it
    block = chain.mineBlock([
      Tx.contractCall('mingle-bridge', 'rsvp-event',
        [types.uint(1), types.bool(true)],
        user1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
  }
});

Clarinet.test({
  name: "Can update user profile",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const user1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('mingle-bridge', 'update-profile',
        [types.list([types.ascii("sports"), types.ascii("music")])],
        user1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
  }
});
