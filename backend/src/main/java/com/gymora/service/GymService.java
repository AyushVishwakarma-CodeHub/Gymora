package com.gymora.service;

import com.gymora.exception.ResourceNotFoundException;
import com.gymora.model.dto.request.GymRequest;
import com.gymora.model.dto.response.GymResponse;
import com.gymora.model.entity.Gym;
import com.gymora.model.entity.User;
import com.gymora.model.enums.GymStatus;
import com.gymora.repository.GymRepository;
import com.gymora.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GymService {

    private final GymRepository gymRepository;
    private final UserRepository userRepository;

    @Transactional
    @CacheEvict(value = "gyms", allEntries = true)
    public GymResponse createGym(GymRequest request) {
        User admin = userRepository.findById(request.getAdminId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", request.getAdminId()));

        Gym gym = Gym.builder()
                .name(request.getName())
                .address(request.getAddress())
                .city(request.getCity())
                .phone(request.getPhone())
                .logoUrl(request.getLogoUrl())
                .description(request.getDescription())
                .admin(admin)
                .status(GymStatus.PENDING)
                .build();

        gym = gymRepository.save(gym);
        return mapToResponse(gym);
    }

    @Cacheable(value = "gyms", key = "#id")
    public GymResponse getGymById(Long id) {
        Gym gym = gymRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Gym", "id", id));
        return mapToResponse(gym);
    }

    public List<GymResponse> getAllGyms() {
        return gymRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<GymResponse> getGymsByAdmin(Long adminId) {
        return gymRepository.findByAdminId(adminId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<GymResponse> getGymsByStatus(GymStatus status) {
        return gymRepository.findByStatus(status).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    @CacheEvict(value = "gyms", allEntries = true)
    public GymResponse updateGym(Long id, GymRequest request) {
        Gym gym = gymRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Gym", "id", id));

        gym.setName(request.getName());
        gym.setAddress(request.getAddress());
        gym.setCity(request.getCity());
        gym.setPhone(request.getPhone());
        if (request.getLogoUrl() != null) gym.setLogoUrl(request.getLogoUrl());
        if (request.getDescription() != null) gym.setDescription(request.getDescription());

        gym = gymRepository.save(gym);
        return mapToResponse(gym);
    }

    @Transactional
    @CacheEvict(value = "gyms", allEntries = true)
    public GymResponse updateGymStatus(Long id, GymStatus status) {
        Gym gym = gymRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Gym", "id", id));
        gym.setStatus(status);
        gym = gymRepository.save(gym);
        return mapToResponse(gym);
    }

    private GymResponse mapToResponse(Gym gym) {
        return GymResponse.builder()
                .id(gym.getId())
                .name(gym.getName())
                .address(gym.getAddress())
                .city(gym.getCity())
                .phone(gym.getPhone())
                .logoUrl(gym.getLogoUrl())
                .description(gym.getDescription())
                .status(gym.getStatus())
                .adminId(gym.getAdmin().getId())
                .adminName(gym.getAdmin().getFullName())
                .trainerCount(gym.getTrainers() != null ? gym.getTrainers().size() : 0)
                .customerCount(gym.getCustomers() != null ? gym.getCustomers().size() : 0)
                .createdAt(gym.getCreatedAt())
                .build();
    }
}
