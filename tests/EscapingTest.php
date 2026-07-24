<?php

use PHPUnit\Framework\TestCase;

final class EscapingTest extends TestCase
{
    public function testEscapesHtmlSpecialChars(): void
    {
        $this->assertSame('&lt;script&gt;alert(1)&lt;/script&gt;', e('<script>alert(1)</script>'));
    }

    public function testEscapesDoubleAndSingleQuotes(): void
    {
        $this->assertSame('&quot;quoted&quot; and &#039;single&#039;', e('"quoted" and \'single\''));
    }

    public function testCoercesNonStringInputToString(): void
    {
        $this->assertSame('42', e(42));
        $this->assertSame('3.5', e(3.5));
    }

    public function testPlainTextPassesThroughUnchanged(): void
    {
        $this->assertSame('Heineken Bottle', e('Heineken Bottle'));
    }
}
