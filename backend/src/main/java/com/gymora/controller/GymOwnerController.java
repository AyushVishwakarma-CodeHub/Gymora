package com.gymora.controller;

import com.gymora.model.dto.request.RegisterRequest;
import com.gymora.model.dto.response.ApiResponse;
import com.gymora.model.dto.response.CustomerResponse;
import com.gymora.model.dto.response.TrainerResponse;
import com.gymora.service.GymOwnerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/gym-owner")
@RequiredArgsConstructor
@PreAuthorize("hasRole('GYM_ADMIN')")
public class GymOwnerController {

    private final GymOwnerService gymOwnerService;

    @PostMapping("/{gymId}/members")
    public ResponseEntity<ApiResponse<CustomerResponse>> addMember(
            @PathVariable Long gymId,
            @RequestBody RegisterRequest request) {
        CustomerResponse customer = gymOwnerService.addMember(gymId, request);
        return ResponseEntity.ok(ApiResponse.success("Member added successfully", customer));
    }

    @PatchMapping("/trainers/{trainerId}/approve")
    public ResponseEntity<ApiResponse<Void>> approveTrainer(@PathVariable Long trainerId) {
        gymOwnerService.approveTrainer(trainerId);
        return ResponseEntity.ok(ApiResponse.success("Trainer approved successfully", null));
    }

    @PostMapping("/{gymId}/trainers")
    public ResponseEntity<ApiResponse<TrainerResponse>> addTrainer(
            @PathVariable Long gymId,
            @RequestBody RegisterRequest request) {
        TrainerResponse trainer = gymOwnerService.addTrainer(gymId, request);
        return ResponseEntity.ok(ApiResponse.success("Trainer added successfully", trainer));
    }
}
