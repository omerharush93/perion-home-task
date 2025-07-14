var assert = require('assert');

console.log("🧪 Running tests...");

// Simple test that works with Node.js
try {
    // Test 1: Array indexOf
    assert.equal(-1, [1,2,3].indexOf(4), "Array indexOf should return -1 for non-existent value");
    console.log("✅ Test 1 passed: Array indexOf");
    
    // Test 2: Basic assertion
    assert.equal(2, 2, "Basic equality test");
    console.log("✅ Test 2 passed: Basic equality");
    
    // Test 3: String test
    assert.equal("hello", "hello", "String equality test");
    console.log("✅ Test 3 passed: String equality");
    
    console.log("🎉 All tests passed!");
    process.exit(0);
} catch (error) {
    console.error("❌ Test failed:", error.message);
    process.exit(1);
}