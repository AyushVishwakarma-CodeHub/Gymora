package com.gymora.service;

import com.gymora.exception.BadRequestException;
import com.gymora.exception.ResourceNotFoundException;
import com.gymora.model.dto.request.RegisterRequest;
import com.gymora.model.dto.response.AuthResponse;
import com.gymora.model.entity.User;
import com.gymora.model.enums.Role;
import com.gymora.repository.UserRepository;
import com.gymora.security.JwtTokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private PasswordEncoder passwordEncoder;
    @Mock private JwtTokenProvider tokenProvider;
    @Mock private AuthenticationManager authenticationManager;

    @InjectMocks private AuthService authService;

    private RegisterRequest registerRequest;
    private User savedUser;

    @BeforeEach
    void setUp() {
        registerRequest = new RegisterRequest();
        registerRequest.setFullName("Test User");
        registerRequest.setEmail("test@gymora.com");
        registerRequest.setPassword("password123");
        registerRequest.setPhone("+919876543210");
        registerRequest.setRole(Role.CUSTOMER);

        savedUser = User.builder()
                .id(1L)
                .fullName("Test User")
                .email("test@gymora.com")
                .passwordHash("encoded_password")
                .phone("+919876543210")
                .role(Role.CUSTOMER)
                .isActive(true)
                .build();
    }

    @Test
    @DisplayName("Should register a new user successfully")
    void register_Success() {
        when(userRepository.existsByEmail(anyString())).thenReturn(false);
        when(passwordEncoder.encode(anyString())).thenReturn("encoded_password");
        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(tokenProvider.generateAccessToken(anyString())).thenReturn("access_token");
        when(tokenProvider.generateRefreshToken(anyString())).thenReturn("refresh_token");
        when(tokenProvider.getAccessTokenExpiration()).thenReturn(900000L);

        AuthResponse response = authService.register(registerRequest);

        assertNotNull(response);
        assertEquals("access_token", response.getAccessToken());
        assertEquals("refresh_token", response.getRefreshToken());
        assertEquals("Test User", response.getUser().getFullName());
        assertEquals(Role.CUSTOMER, response.getUser().getRole());

        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("Should throw BadRequestException for duplicate email")
    void register_DuplicateEmail() {
        when(userRepository.existsByEmail(anyString())).thenReturn(true);

        assertThrows(BadRequestException.class, () -> authService.register(registerRequest));

        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Should return current user by email")
    void getCurrentUser_Success() {
        when(userRepository.findByEmail("test@gymora.com")).thenReturn(java.util.Optional.of(savedUser));

        var response = authService.getCurrentUser("test@gymora.com");

        assertNotNull(response);
        assertEquals(1L, response.getId());
        assertEquals("Test User", response.getFullName());
    }

    @Test
    @DisplayName("Should throw when user not found")
    void getCurrentUser_NotFound() {
        when(userRepository.findByEmail("unknown@gymora.com")).thenReturn(java.util.Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> authService.getCurrentUser("unknown@gymora.com"));
    }
}
