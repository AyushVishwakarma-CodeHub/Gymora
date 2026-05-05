package com.gymora.repository;

import com.gymora.model.entity.WorkoutPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WorkoutPlanRepository extends JpaRepository<WorkoutPlan, Long> {

    List<WorkoutPlan> findByCustomerId(Long customerId);

    List<WorkoutPlan> findByTrainerId(Long trainerId);

    List<WorkoutPlan> findByCustomerIdAndIsActiveTrue(Long customerId);

    List<WorkoutPlan> findByTrainerIdAndIsActiveTrue(Long trainerId);
}
