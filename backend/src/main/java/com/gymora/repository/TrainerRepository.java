package com.gymora.repository;

import com.gymora.model.entity.Trainer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TrainerRepository extends JpaRepository<Trainer, Long> {

    List<Trainer> findByGymId(Long gymId);

    Optional<Trainer> findByUserId(Long userId);

    List<Trainer> findByGymIdAndIsActiveTrue(Long gymId);

    Long countByGymId(Long gymId);
}
