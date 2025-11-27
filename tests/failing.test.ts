import { test, describe } from "node:test";
import assert from "node:assert";

describe("Failing Tests", () => {
  test("should pass", () => {
    assert.equal(2 + 2, 4);
  });

  test("should fail", () => {
    assert.equal(2 + 2, 5);
  });
});

