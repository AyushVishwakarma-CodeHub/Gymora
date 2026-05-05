package com.gymora.repository;

import com.gymora.model.entity.DietPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DietPlanRepository extends JpaRepository<DietPlan, Long> {

    List<DietPlan> findByCustomerId(Long customerId);

    List<DietPlan> findByTrainerId(Long trainerId);

    List<DietPlan> findByCustomerIdAndIsActiveTrue(Long customerId);
}
