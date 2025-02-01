import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Test vault creation",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("vault", "create-vault", [types.uint(1000)], wallet_1.address)
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), true);
  },
});

Clarinet.test({
  name: "Test deposit and withdrawal",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("vault", "create-vault", [types.uint(1000)], wallet_1.address),
      Tx.contractCall("vault", "deposit", [types.uint(500)], wallet_1.address),
      Tx.contractCall("vault", "withdraw", [types.uint(200)], wallet_1.address)
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), true);
    assertEquals(block.receipts[1].result.expectOk(), true);
    assertEquals(block.receipts[2].result.expectOk(), true);
  },
});
