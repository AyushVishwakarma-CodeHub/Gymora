package com.gymora.repository;

import com.gymora.model.entity.ActivityLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface ActivityLogRepository extends JpaRepository<ActivityLog, Long> {

    List<ActivityLog> findByCustomerIdOrderByLogDateDesc(Long customerId);

    List<ActivityLog> findByCustomerIdAndLogDateBetweenOrderByLogDateAsc(
            Long customerId, LocalDate startDate, LocalDate endDate);

    Optional<ActivityLog> findByCustomerIdAndLogDate(Long customerId, LocalDate logDate);

    @Query("SELECT a FROM ActivityLog a WHERE a.customer.id = :customerId ORDER BY a.logDate DESC LIMIT 30")
    List<ActivityLog> findRecentByCustomerId(@Param("customerId") Long customerId);
}
