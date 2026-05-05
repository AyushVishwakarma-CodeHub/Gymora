package com.gymora.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "activity_logs", indexes = {
    @Index(name = "idx_activity_logs_customer_date", columnList = "customer_id, log_date")
})
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class ActivityLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @Column(nullable = false)
    private LocalDate logDate;

    @Column(precision = 5, scale = 2)
    private BigDecimal weightKg;

    @Column(precision = 4, scale = 2)
    private BigDecimal bmi;

    private Integer caloriesConsumed;

    private Integer caloriesBurned;

    private Integer steps;

    private Integer waterMl;

    @Column(columnDefinition = "TEXT")
    private String notes;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;
}
