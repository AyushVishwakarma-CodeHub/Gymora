package com.gymora.model.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "trainers", indexes = {
    @Index(name = "idx_trainers_user_id", columnList = "user_id"),
    @Index(name = "idx_trainers_gym_id", columnList = "gym_id")
})
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
public class Trainer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "gym_id", nullable = false)
    private Gym gym;

    private String specialization;

    private Integer experienceYears;

    @Column(columnDefinition = "TEXT")
    private String bio;

    @Builder.Default
    @Column(nullable = false)
    private Boolean isActive = true;

    @OneToMany(mappedBy = "trainer", cascade = CascadeType.ALL)
    @Builder.Default
    private List<Customer> customers = new ArrayList<>();

    @OneToMany(mappedBy = "trainer", cascade = CascadeType.ALL)
    @Builder.Default
    private List<WorkoutPlan> workoutPlans = new ArrayList<>();

    @OneToMany(mappedBy = "trainer", cascade = CascadeType.ALL)
    @Builder.Default
    private List<DietPlan> dietPlans = new ArrayList<>();

    @Column(nullable = true)
    @Builder.Default
    private Boolean isApproved = false;

    @Column(columnDefinition = "TEXT")
    private String certifications;

    @Column(columnDefinition = "TEXT")
    private String socialLinks;

    @CreationTimestamp
    @Column(updatable = false)
    private LocalDateTime createdAt;
}
