package com.gymora.repository;

import com.gymora.model.entity.Gym;
import com.gymora.model.enums.GymStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface GymRepository extends JpaRepository<Gym, Long> {

    List<Gym> findByAdminId(Long adminId);

    List<Gym> findByStatus(GymStatus status);

    Long countByStatus(GymStatus status);
}
