<?php

use PHPUnit\Framework\TestCase;

final class MoneyFormattingTest extends TestCase
{
    public function testFormatsWithNairaSignAndTwoDecimals(): void
    {
        $this->assertSame('₦1,234.50', money(1234.5));
    }

    public function testFormatsZero(): void
    {
        $this->assertSame('₦0.00', money(0));
    }

    public function testFormatsNegativeAmounts(): void
    {
        // money() just formats whatever it's given — callers (refund/void
        // displays) are responsible for prepending their own +/- sign.
        $this->assertSame('₦-50.00', money(-50));
    }

    public function testRoundsToTwoDecimalPlaces(): void
    {
        $this->assertSame('₦10.00', money(9.999));
        $this->assertSame('₦10.01', money(10.005));
    }

    public function testAcceptsNumericStrings(): void
    {
        // callers frequently pass DECIMAL columns fetched via PDO, which arrive as strings
        $this->assertSame('₦100.00', money('100'));
    }

    public function testFormatsLargeAmountsWithThousandsSeparators(): void
    {
        $this->assertSame('₦1,000,000.00', money(1000000));
    }
}
