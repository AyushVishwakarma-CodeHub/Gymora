package com.gymora.repository;

import com.gymora.model.entity.Membership;
import com.gymora.model.enums.MembershipStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface MembershipRepository extends JpaRepository<Membership, Long> {

    List<Membership> findByCustomerId(Long customerId);

    List<Membership> findByGymId(Long gymId);

    Optional<Membership> findByCustomerIdAndStatus(Long customerId, MembershipStatus status);

    List<Membership> findByCustomerIdAndStatusIn(Long customerId, List<MembershipStatus> statuses);

    @Query("SELECT m FROM Membership m WHERE m.endDate BETWEEN :startDate AND :endDate AND m.status = 'ACTIVE'")
    List<Membership> findExpiringMemberships(@Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);

    Long countByGymIdAndStatus(Long gymId, MembershipStatus status);

    @Query("SELECT COUNT(m) FROM Membership m WHERE m.status = 'ACTIVE'")
    Long countActiveMembers();
}
