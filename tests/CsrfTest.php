<?php

use PHPUnit\Framework\TestCase;

final class CsrfTest extends TestCase
{
    protected function setUp(): void
    {
        $_SESSION = [];
        unset($_POST['_csrf'], $_SERVER['HTTP_X_CSRF_TOKEN']);
    }

    public function testGeneratesATokenWhenNoneExists(): void
    {
        $token = csrfToken();
        $this->assertNotEmpty($token);
        $this->assertSame(64, strlen($token)); // bin2hex(random_bytes(32)) => 64 hex chars
    }

    public function testReturnsTheSameTokenOnSubsequentCalls(): void
    {
        $first  = csrfToken();
        $second = csrfToken();
        $this->assertSame($first, $second);
    }

    public function testCsrfFieldEmbedsTheCurrentToken(): void
    {
        $token = csrfToken();
        $field = csrfField();
        $this->assertStringContainsString('name="_csrf"', $field);
        $this->assertStringContainsString('value="' . $token . '"', $field);
    }

    public function testVerifyCsrfPassesSilentlyOnNonPostRequests(): void
    {
        $_SERVER['REQUEST_METHOD'] = 'GET';
        // Should not exit for a GET request regardless of token state.
        verifyCsrf();
        $this->assertTrue(true); // reaching this line means it didn't die()
    }

    public function testVerifyCsrfPassesWithAMatchingToken(): void
    {
        $token = csrfToken();
        $_SERVER['REQUEST_METHOD'] = 'POST';
        $_POST['_csrf'] = $token;
        verifyCsrf();
        $this->assertTrue(true);
    }

    // Note: the mismatched-token path is intentionally not covered here —
    // verifyCsrf() calls die() on failure, which would kill the test runner
    // itself. Exercising that branch safely would mean refactoring verifyCsrf()
    // to throw an exception instead of dying, which is a behavior change
    // outside what this test suite was asked to cover.
}
