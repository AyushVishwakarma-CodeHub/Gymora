package com.gymora.service;

import com.gymora.exception.BadRequestException;
import com.gymora.exception.ResourceNotFoundException;
import com.gymora.model.enums.Role;
import com.gymora.model.dto.request.LoginRequest;
import com.gymora.model.dto.request.RegisterRequest;
import com.gymora.model.dto.response.AuthResponse;
import com.gymora.model.dto.response.UserResponse;
import com.gymora.model.entity.User;
import com.gymora.repository.UserRepository;
import com.gymora.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final com.gymora.repository.TrainerRepository trainerRepository;
    private final com.gymora.repository.GymRepository gymRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Email is already registered");
        }

        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .role(request.getRole())
                .address(request.getAddress())
                .isActive(true)
                .build();

        user = userRepository.save(user);

        if (request.getRole() == Role.TRAINER) {
            if (request.getGymId() == null) {
                throw new BadRequestException("Gym selection is required for trainers");
            }
            
            com.gymora.model.entity.Gym gym = gymRepository.findById(request.getGymId())
                    .orElseThrow(() -> new ResourceNotFoundException("Gym", "id", request.getGymId()));

            com.gymora.model.entity.Trainer trainer = com.gymora.model.entity.Trainer.builder()
                    .user(user)
                    .gym(gym)
                    .specialization(request.getSpecialization())
                    .experienceYears(request.getExperienceYears())
                    .bio(request.getBio())
                    .certifications(request.getCertifications())
                    .socialLinks(request.getSocialLinks())
                    .isApproved(false)
                    .isActive(true)
                    .build();
            
            trainerRepository.save(trainer);
        }

        String accessToken = tokenProvider.generateAccessToken(user.getEmail());
        String refreshToken = tokenProvider.generateRefreshToken(user.getEmail());

        return AuthResponse.of(
                accessToken,
                refreshToken,
                tokenProvider.getAccessTokenExpiration(),
                mapToUserResponse(user)
        );
    }

    public AuthResponse login(LoginRequest request) {
        long startTime = System.currentTimeMillis();
        log.info("Starting login process for email: {}", request.getEmail());

        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );
        } catch (Exception e) {
            log.error("Authentication failed for email: {} - Error: {}", request.getEmail(), e.getMessage());
            throw e;
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", request.getEmail()));

        String accessToken = tokenProvider.generateAccessToken(request.getEmail());
        String refreshToken = tokenProvider.generateRefreshToken(user.getEmail());

        log.info("Login successful for email: {}. Total time: {}ms",
                request.getEmail(), (System.currentTimeMillis() - startTime));

        return AuthResponse.of(
                accessToken,
                refreshToken,
                tokenProvider.getAccessTokenExpiration(),
                mapToUserResponse(user)
        );
    }

    public AuthResponse refreshToken(String refreshToken) {
        if (!tokenProvider.validateToken(refreshToken)) {
            throw new BadRequestException("Invalid refresh token");
        }

        String email = tokenProvider.getEmailFromToken(refreshToken);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));

        String newAccessToken = tokenProvider.generateAccessToken(email);
        String newRefreshToken = tokenProvider.generateRefreshToken(email);

        return AuthResponse.of(
                newAccessToken,
                newRefreshToken,
                tokenProvider.getAccessTokenExpiration(),
                mapToUserResponse(user)
        );
    }

    public UserResponse getCurrentUser(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));
        return mapToUserResponse(user);
    }

    private UserResponse mapToUserResponse(User user) {
        boolean isApproved = true; // Default (Admin, Gym Admin, Customer)
        if (user.getRole() == Role.TRAINER) {
            isApproved = trainerRepository.findByUserId(user.getId())
                    .map(com.gymora.model.entity.Trainer::getIsApproved)
                    .orElse(false);
        }

        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .avatarUrl(user.getAvatarUrl())
                .address(user.getAddress())
                .role(user.getRole())
                .isActive(user.getIsActive())
                .isApproved(isApproved)
                .createdAt(user.getCreatedAt())
                .build();
    }
}
