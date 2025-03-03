import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create a new event with end time",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const futureDate = chain.blockHeight + 100;
    const endTime = futureDate + 10;
    
    let block = chain.mineBlock([
      Tx.contractCall('mingle-bridge', 'create-event',
        [
          types.ascii("Beach Party"),
          types.ascii("Summer fun!"),
          types.uint(futureDate),
          types.uint(endTime),
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
  name: "Can cancel an event",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const futureDate = chain.blockHeight + 100;
    const endTime = futureDate + 10;
    
    let block = chain.mineBlock([
      Tx.contractCall('mingle-bridge', 'create-event',
        [
          types.ascii("Beach Party"),
          types.ascii("Summer fun!"),
          types.uint(futureDate),
          types.uint(endTime),
          types.uint(100)
        ],
        deployer.address
      ),
      Tx.contractCall('mingle-bridge', 'cancel-event',
        [types.uint(1)],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 2);
    block.receipts[1].result.expectOk().expectBool(true);
  }
});

// Include existing tests...
