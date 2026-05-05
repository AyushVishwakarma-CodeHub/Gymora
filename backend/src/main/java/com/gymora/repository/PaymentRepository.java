package com.gymora.repository;

import com.gymora.model.entity.Payment;
import com.gymora.model.enums.PaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {

    List<Payment> findByCustomerId(Long customerId);

    List<Payment> findByMembershipId(Long membershipId);

    @Query("SELECT p FROM Payment p WHERE p.membership.gym.id = :gymId")
    List<Payment> findByGymId(@Param("gymId") Long gymId);

    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = 'COMPLETED'")
    BigDecimal getTotalRevenue();

    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.status = 'COMPLETED' AND p.paidAt >= :startDate")
    BigDecimal getRevenueAfterDate(@Param("startDate") LocalDateTime startDate);

    @Query("SELECT COALESCE(SUM(p.amount), 0) FROM Payment p WHERE p.membership.gym.id = :gymId AND p.status = 'COMPLETED'")
    BigDecimal getGymTotalRevenue(@Param("gymId") Long gymId);
}
