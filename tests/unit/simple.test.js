/**
 * Simple tests to verify the test environment works
 */

describe('Agent Adam Project', () => {
  test('project structure is valid', () => {
    expect(true).toBe(true);
  });

  test('JavaScript modules work', () => {
    const testFunction = (a, b) => a + b;
    expect(testFunction(2, 3)).toBe(5);
  });

  test('environment variables are loaded', () => {
    // Test that we can access environment
    expect(process.env.NODE_ENV).toBeDefined();
  });

  test('basic string manipulation works', () => {
    const message = "Hello Agent Adam";
    expect(message.toLowerCase()).toBe("hello agent adam");
    expect(message.includes("Agent")).toBe(true);
  });

  test('async operations work', async () => {
    const asyncFunction = async () => {
      return new Promise(resolve => {
        setTimeout(() => resolve('success'), 10);
      });
    };

    const result = await asyncFunction();
    expect(result).toBe('success');
  });
});