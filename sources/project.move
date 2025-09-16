module MyModule::AgeVerification {
    use aptos_framework::signer;
    use aptos_framework::timestamp;

    /// Error codes
    const E_UNDERAGE: u64 = 1;
    const E_ALREADY_VERIFIED: u64 = 2;
    const E_NOT_VERIFIED: u64 = 3;

    /// Struct representing an age verification token for a user
    struct AgeToken has store, key {
        age: u8,              // User's verified age
        verified_at: u64,     // Timestamp when verification occurred
        is_adult: bool,       // Whether user is 18+ for age-restricted services
    }

    /// Function to issue age verification token after age verification
    /// Only users 18+ will get adult status for age-restricted services
    public fun issue_age_token(user: &signer, verified_age: u8) {
        let user_addr = signer::address_of(user);
        
        // Check if user already has a verification token
        assert!(!exists<AgeToken>(user_addr), E_ALREADY_VERIFIED);
        
        // Check minimum age requirement (must be at least 13)
        assert!(verified_age >= 13, E_UNDERAGE);
        
        // Create age verification token
        let age_token = AgeToken {
            age: verified_age,
            verified_at: timestamp::now_seconds(),
            is_adult: verified_age >= 18,
        };
        
        // Store the token in user's account
        move_to(user, age_token);
    }

    /// Function to check if user has valid age verification for restricted services
    /// Returns true if user is verified as adult (18+)
    public fun verify_adult_access(user_addr: address): bool acquires AgeToken {
        // Check if user has verification token
        assert!(exists<AgeToken>(user_addr), E_NOT_VERIFIED);
        
        let age_token = borrow_global<AgeToken>(user_addr);
        
        // Return adult status for age-restricted service access
        age_token.is_adult
    }
}