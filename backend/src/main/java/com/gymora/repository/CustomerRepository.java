package com.gymora.repository;

import com.gymora.model.entity.Customer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerRepository extends JpaRepository<Customer, Long> {

    List<Customer> findByGymId(Long gymId);

    Optional<Customer> findByUserId(Long userId);

    List<Customer> findByTrainerId(Long trainerId);

    Long countByGymId(Long gymId);
}
