<?php

use PHPUnit\Framework\TestCase;

// calcTax()/calcTotal() accept an optional explicit $rate specifically so this
// math is testable without a database — production call sites omit it and get
// the real configured rate via getTaxRate()/getSetting().
final class TaxCalculationTest extends TestCase
{
    public function testZeroRateAddsNoTax(): void
    {
        $this->assertSame(0.0, calcTax(1000, 0));
    }

    public function testTenPercentRate(): void
    {
        $this->assertSame(100.0, calcTax(1000, 10));
    }

    public function testFractionalRate(): void
    {
        $this->assertSame(75.5, calcTax(1000, 7.55));
    }

    public function testRoundsToTwoDecimalPlaces(): void
    {
        $this->assertSame(33.33, calcTax(100, 33.333));
    }

    public function testNegativeRateIsTreatedAsNoTax(): void
    {
        // Shouldn't happen in practice — getTaxRate() floors at 0 before
        // calcTax ever sees it — but calcTax itself only applies tax when
        // rate > 0, so a stray negative falls through to "no tax" rather
        // than subtracting.
        $this->assertSame(0.0, calcTax(1000, -5));
    }

    public function testCalcTotalAddsSubtotalAndTax(): void
    {
        $this->assertSame(1100.0, calcTotal(1000, 10));
    }

    public function testCalcTotalWithZeroTax(): void
    {
        $this->assertSame(500.0, calcTotal(500, 0));
    }
}
