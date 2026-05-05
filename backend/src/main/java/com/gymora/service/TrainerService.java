package com.gymora.service;

import com.gymora.exception.ResourceNotFoundException;
import com.gymora.model.dto.request.TrainerRequest;
import com.gymora.model.dto.response.TrainerResponse;
import com.gymora.model.entity.Gym;
import com.gymora.model.entity.Trainer;
import com.gymora.model.entity.User;
import com.gymora.repository.GymRepository;
import com.gymora.repository.TrainerRepository;
import com.gymora.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TrainerService {

    private final TrainerRepository trainerRepository;
    private final UserRepository userRepository;
    private final GymRepository gymRepository;

    @Transactional
    public TrainerResponse createTrainer(TrainerRequest request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", request.getUserId()));
        Gym gym = gymRepository.findById(request.getGymId())
                .orElseThrow(() -> new ResourceNotFoundException("Gym", "id", request.getGymId()));

        Trainer trainer = Trainer.builder()
                .user(user)
                .gym(gym)
                .specialization(request.getSpecialization())
                .experienceYears(request.getExperienceYears())
                .bio(request.getBio())
                .isActive(true)
                .build();

        trainer = trainerRepository.save(trainer);
        return mapToResponse(trainer);
    }

    public TrainerResponse getTrainerById(Long id) {
        Trainer trainer = trainerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Trainer", "id", id));
        return mapToResponse(trainer);
    }

    public TrainerResponse getTrainerByUserId(Long userId) {
        Trainer trainer = trainerRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Trainer", "userId", userId));
        return mapToResponse(trainer);
    }

    public List<TrainerResponse> getTrainersByGym(Long gymId) {
        return trainerRepository.findByGymIdAndIsActiveTrue(gymId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public TrainerResponse updateTrainer(Long id, TrainerRequest request) {
        Trainer trainer = trainerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Trainer", "id", id));

        if (request.getSpecialization() != null) trainer.setSpecialization(request.getSpecialization());
        if (request.getExperienceYears() != null) trainer.setExperienceYears(request.getExperienceYears());
        if (request.getBio() != null) trainer.setBio(request.getBio());

        trainer = trainerRepository.save(trainer);
        return mapToResponse(trainer);
    }

    private TrainerResponse mapToResponse(Trainer trainer) {
        return TrainerResponse.builder()
                .id(trainer.getId())
                .userId(trainer.getUser().getId())
                .fullName(trainer.getUser().getFullName())
                .email(trainer.getUser().getEmail())
                .avatarUrl(trainer.getUser().getAvatarUrl())
                .gymId(trainer.getGym().getId())
                .gymName(trainer.getGym().getName())
                .specialization(trainer.getSpecialization())
                .experienceYears(trainer.getExperienceYears())
                .bio(trainer.getBio())
                .isActive(trainer.getIsActive())
                .customerCount(trainer.getCustomers() != null ? trainer.getCustomers().size() : 0)
                .createdAt(trainer.getCreatedAt())
                .build();
    }
}
