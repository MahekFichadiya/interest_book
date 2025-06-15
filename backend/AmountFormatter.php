<?php

/**
 * Utility class for formatting amounts and currency values consistently
 * throughout the PHP backend
 */
class AmountFormatter {
    
    /**
     * Format amount as Indian currency with proper decimal places
     * @param float|string $amount The amount to format
     * @param int $decimals Number of decimal places (default: 2)
     * @return float Formatted amount as float
     */
    public static function formatCurrency($amount, $decimals = 2) {
        if ($amount === null || $amount === '') {
            return 0.0;
        }
        
        $value = floatval($amount);
        return round($value, $decimals);
    }
    
    /**
     * Format amount for whole numbers (principal amounts)
     * @param float|string $amount The amount to format
     * @return int Formatted amount as integer
     */
    public static function formatWholeAmount($amount) {
        if ($amount === null || $amount === '') {
            return 0;
        }
        
        return intval(round(floatval($amount)));
    }
    
    /**
     * Format percentage with proper decimal places
     * @param float|string $percentage The percentage to format
     * @param int $decimals Number of decimal places (default: 2)
     * @return float Formatted percentage as float
     */
    public static function formatPercentage($percentage, $decimals = 2) {
        if ($percentage === null || $percentage === '') {
            return 0.0;
        }
        
        return round(floatval($percentage), $decimals);
    }
    
    /**
     * Format amount for database storage (ensures proper numeric format)
     * @param float|string $amount The amount to format
     * @return string Formatted amount as string for database
     */
    public static function formatForStorage($amount) {
        if ($amount === null || $amount === '') {
            return '0';
        }
        
        return strval(floatval($amount));
    }
    
    /**
     * Calculate daily interest from monthly interest
     * @param float|string $monthlyAmount Monthly interest amount
     * @return float Daily interest amount
     */
    public static function calculateDailyInterest($monthlyAmount) {
        $monthly = floatval($monthlyAmount);
        return round($monthly / 30, 2);
    }
    
    /**
     * Calculate monthly interest from daily interest
     * @param float|string $dailyAmount Daily interest amount
     * @return float Monthly interest amount
     */
    public static function calculateMonthlyInterest($dailyAmount) {
        $daily = floatval($dailyAmount);
        return round($daily * 30, 2);
    }
    
    /**
     * Validate if amount is positive
     * @param float|string $amount The amount to validate
     * @return bool True if positive, false otherwise
     */
    public static function isPositive($amount) {
        return floatval($amount) > 0;
    }
    
    /**
     * Validate if amount is negative
     * @param float|string $amount The amount to validate
     * @return bool True if negative, false otherwise
     */
    public static function isNegative($amount) {
        return floatval($amount) < 0;
    }
    
    /**
     * Format response data with consistent amount formatting
     * @param array $data Array of data to format
     * @return array Formatted data array
     */
    public static function formatResponseData($data) {
        $formatted = [];
        
        foreach ($data as $key => $value) {
            if (in_array($key, ['amount', 'originalAmount', 'remainingBalance', 'totalDeposits'])) {
                // Format as whole amounts for principal/deposit amounts
                $formatted[$key] = self::formatWholeAmount($value);
            } elseif (in_array($key, ['monthlyInterest', 'totalAccumulatedInterest', 'totalInterestPaid', 'netAmountDue'])) {
                // Format with decimals for interest calculations
                $formatted[$key] = self::formatCurrency($value, 2);
            } elseif (in_array($key, ['rate', 'monthlyInterestRate'])) {
                // Format percentages
                $formatted[$key] = self::formatPercentage($value, 2);
            } else {
                // Keep other values as is
                $formatted[$key] = $value;
            }
        }
        
        return $formatted;
    }
}

?>
